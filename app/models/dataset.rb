# frozen_string_literal: true

class Dataset < ApplicationRecord
  FILES_PER_PAGE = 100

  mount_uploader :logo, ImageUploader

  # Callbacks
  after_create_commit :create_folders
  after_touch :recalculate_rating!

  # Concerns
  include Deletable, Documentable, Gitable, Forkable

  # Scopes
  scope :released, -> { current.where(released: true) }
  scope :with_editor, ->(arg) { where("datasets.user_id IN (?) or datasets.id in (select dataset_users.dataset_id from dataset_users where dataset_users.user_id = ? and dataset_users.role = ?)", arg, arg, "editor").references(:dataset_users) }
  scope :with_reviewer, ->(arg) { where("datasets.id in (select dataset_users.dataset_id from dataset_users where dataset_users.user_id = ? and dataset_users.role = ?)", arg, "reviewer").references(:dataset_users) }
  scope :with_viewer_or_editor, ->(arg) { where("datasets.released = ? or datasets.user_id IN (?) or datasets.id in (select dataset_users.dataset_id from dataset_users where dataset_users.user_id = ? and dataset_users.role IN (?))", true, arg, arg, %w(viewer editor)).references(:dataset_users) }
  scope :with_viewer_or_editor_or_approved, ->(arg) { where("datasets.released = ? or datasets.user_id IN (?) or datasets.id in (select dataset_users.dataset_id from dataset_users where dataset_users.user_id = ? and dataset_users.role IN (?)) or datasets.id in (select requests.dataset_id from datasets INNER JOIN requests ON requests.dataset_id = datasets.id INNER JOIN agreements ON agreements.id = requests.agreement_id AND agreements.deleted = ? WHERE (agreements.expiration_date IS NULL OR (agreements.expiration_date >= ?)) AND agreements.status = ? AND agreements.user_id = ?)", true, arg, arg, %w(viewer editor), false, Time.zone.today, "approved", arg) }

  # Validations
  validates :name, :slug, :user_id, presence: true
  validates :slug, uniqueness: { scope: :deleted, case_sensitive: false }
  validates :slug, format: { with: /\A(?!\Anew\Z)[a-z][a-z0-9\-]*\Z/ }

  # Relationships
  belongs_to :user
  belongs_to :dataset_version, optional: true
  belongs_to :organization, optional: true
  has_many :dataset_versions
  has_many :dataset_file_audits
  has_many :dataset_page_audits
  has_many :dataset_users
  has_many :domains
  has_many :forms
  has_many :variables
  has_many :variable_forms
  has_many :requests
  has_many :agreements, -> { current }, through: :requests
  has_many :data_requests, -> { current }, through: :requests, source: :agreement, class_name: "DataRequest"
  has_many :dataset_files
  has_many :dataset_reviews, -> { order(rating: :desc, id: :desc) }
  has_many :legal_document_datasets
  has_many :legal_documents, through: :legal_document_datasets
  has_many :final_legal_documents, -> { order(published_at: :desc) }, through: :legal_documents

  def recalculate_rating!
    ratings = dataset_reviews.where.not(rating: nil).pluck(:rating)
    update rating: ratings.present? ? ratings.inject(&:+).to_f / ratings.count : 3
  end

  def chartable_variables
    variables.order("commonly_used desc", :folder, :name)
  end

  def current_variables
    variables.where(dataset_version_id: dataset_version)
  end

  def editor?(current_user)
    return false unless current_user
    editors.where(id: current_user).count == 1
  end

  def editors
    User.where(id: [user_id] + dataset_users.where(role: "editor").pluck(:user_id))
  end

  def reviewers
    User.where(id: dataset_users.where(role: "reviewer").select(:user_id))
  end

  def viewers
    User.where(id: [user_id] + dataset_users.where(role: "viewer").pluck(:user_id))
  end

  def approved_data_request?(current_user)
    agreements.where(status: "approved", user: current_user).not_expired.count.positive?
  end

  def to_param
    slug_was
  end

  def self.find_by_param(input)
    find_by(slug: input)
  end

  def folder_name
    Rails.env.test? ? slug : id.to_s
  end

  def root_folder
    File.join(CarrierWave::Uploader::Base.root, "datasets", folder_name)
  end

  def files_folder
    File.join(root_folder, "files")
  end

  def reset_index_in_background!(path, recompute: false)
    fork_process(:reset_index!, path, recompute: recompute)
  end

  def reset_index!(params_path, recompute: false)
    full_path = find_file(params_path)
    return unless full_path && File.directory?(full_path)
    path = full_path.gsub(%r{^#{files_folder}/}, "")
    # FileUtils.mkpath(full_path) # TODO: Potentially add this.
    generate_new_files_in_folder_with_lock(path, recompute: recompute)
  end

  def generate_new_files_in_folder_with_lock(path, recompute: false)
    lock_folder!(path)
    prune_existing_dataset_files(path, recompute: recompute)
    generate_new_files_in_folder(path)
  ensure
    lock_file = File.join(files_folder, path.to_s, ".sleepdata.md5inprogress")
    File.delete(lock_file) if File.exist?(lock_file) && File.file?(lock_file)
  end

  def lock_folder!(location = nil)
    lock_file = File.join(files_folder, location.to_s, ".sleepdata.md5inprogress")
    File.write(lock_file, "")
  end

  def prune_existing_dataset_files(path, recompute: false)
    folder = path.blank? ? "" : "#{path}/"
    dataset_files.where(folder: folder).update_all file_checksum_md5: nil if recompute
    dataset_files.where(folder: folder).find_each(&:verify_file!)
  end

  def non_root_dataset_files
    dataset_files.current.where.not(file_name: "")
  end

  def all_files(path)
    Dir.glob(File.join(files_folder, path.to_s)) + Dir.glob(File.join(files_folder, path.to_s, "*"))
  end

  def generate_new_files_in_folder(path)
    all_files(path).each do |file|
      find_or_create_dataset_file(file)
    end
  end

  def find_or_create_dataset_file(file)
    full_path = file.gsub(%r{^#{files_folder}/}, "")
    file_name = File.basename(full_path)
    folder = full_path.gsub(/#{file_name}$/, "")
    file_size = File.size(file)
    file_time = File.mtime(file)
    is_file = File.file?(file)
    dataset_file = dataset_files.where(full_path: full_path)
                                .first_or_create(
                                  folder: folder, file_name: file_name,
                                  file_size: file_size, file_time: file_time,
                                  is_file: is_file
                                )
    dataset_file.update(
      folder: folder, file_name: file_name, file_size: file_size,
      file_time: file_time, is_file: is_file, deleted: false
    )
    dataset_file.generate_checksum_md5!
    # These are set elsewhere and shouldn't be overwritten
    # :publicly_available, :archived
  end

  def current_folder_locked?(location)
    lock_file = File.join(files_folder, location.to_s, ".sleepdata.md5inprogress")
    File.exist?(lock_file)
  end

  def file_path(file)
    file.gsub(files_folder + "/", "")
  end

  def find_file_folder(path)
    folders = path.to_s.split("/").collect(&:strip)
    clean_folder_path = nil
    # Navigate to relative folder
    folders.each do |folder|
      dataset_file = dataset_files.current.find_by(full_path: [clean_folder_path, folder].compact.join("/"), is_file: false)
      if dataset_file
        clean_folder_path = [clean_folder_path, dataset_file.file_name].compact.join("/")
      else
        break
      end
    end
    clean_folder_path.to_s
  end

  def find_file(path)
    folders = path.to_s.split("/")[0..-2].collect(&:strip)
    name = path.to_s.split("/").last.to_s.strip
    clean_folder_path = find_file_folder(folders.join("/"))
    entries = Dir.entries(File.join(files_folder, clean_folder_path)).reject { |e| e.first == "." }
    clean_file_name = entries.find { |e| e == name }
    File.join(files_folder, clean_folder_path, clean_file_name.to_s)
  end

  def recompute_datasets_folder_indices_in_background(folders)
    fork_process(:recompute_datasets_folder_indices, folders)
  end

  def recompute_datasets_folder_indices(folders)
    reset_index!(nil, recompute: true)
    folders.each do |folder|
      if File.exist?(File.join(files_folder, folder))
        reset_index!(folder, recompute: true)
      end
    end
  end

  def create_page_audit!(current_user, page_path, remote_ip)
    dataset_page_audits.create(user_id: (current_user ? current_user.id : nil),
                               page_path: page_path,
                               remote_ip: remote_ip)
  end

  def info_present?
    info_what.present? || info_who.present? || info_when.present? || info_funded_by.present?
  end

  def create_folders
    FileUtils.mkdir_p files_folder
  end

  def final_legal_document_for_user(current_user)
    final_legal_documents.find_by(data_user_type: ["both", current_user&.data_user_type], commercial_type: ["both", current_user&.commercial_type])
  end

  def specify_data_user_type?(current_user)
    current_user&.data_user_type.blank? && final_legal_documents.count.positive? && final_legal_documents.where(data_user_type: "both").count.zero?
  end

  def specify_commercial_type?(current_user)
    current_user&.commercial_type.blank? && final_legal_documents.count.positive? && final_legal_documents.where(commercial_type: "both").count.zero?
  end
end
