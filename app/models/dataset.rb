# frozen_string_literal: true

class Dataset < ApplicationRecord
  FILES_PER_PAGE = 100

  mount_uploader :logo, ImageUploader

  # Callbacks
  after_create_commit :create_folders
  after_touch :recalculate_rating!

  # Concerns
  include Deletable, Documentable, Gitable, Forkable

  # Named Scopes
  scope :release_scheduled, -> { current.where(public: true).where.not(release_date: nil) }
  scope :with_editor, -> (arg) { where('datasets.user_id IN (?) or datasets.id in (select dataset_users.dataset_id from dataset_users where dataset_users.user_id = ? and dataset_users.role = ?)', arg, arg, 'editor').references(:dataset_users) }
  scope :with_reviewer, -> (arg) { where('datasets.id in (select dataset_users.dataset_id from dataset_users where dataset_users.user_id = ? and dataset_users.role = ?)', arg, 'reviewer').references(:dataset_users) }
  scope :with_viewer_or_editor, -> (arg) { where('datasets.public = ? or datasets.user_id IN (?) or datasets.id in (select dataset_users.dataset_id from dataset_users where dataset_users.user_id = ? and dataset_users.role IN (?))', true, arg, arg, %w(viewer editor)).references(:dataset_users) }

  # Model Validation
  validates :name, :slug, :user_id, presence: true
  validates :slug, uniqueness: { scope: :deleted, case_sensitive: false }
  validates :slug, format: { with: /\A[a-z][a-z0-9\-]*\Z/ }

  # Model Relationships
  belongs_to :user
  belongs_to :dataset_version
  has_many :dataset_versions
  has_many :dataset_file_audits
  has_many :dataset_page_audits
  has_many :dataset_users
  has_many :domains
  has_many :forms
  has_many :variables
  has_many :variable_forms
  has_many :requests
  has_many :agreements, -> { where deleted: false }, through: :requests

  has_many :dataset_files
  has_many :dataset_reviews, -> { order(rating: :desc, id: :desc) }

  def recalculate_rating!
    ratings = dataset_reviews.where.not(rating: nil).pluck(:rating)
    update rating: ratings.present? ? ratings.inject(&:+).to_f / ratings.count : 3
  end

  def chartable_variables
    variables.order('commonly_used desc', :folder, :name)
  end

  def current_variables
    variables.where(dataset_version_id: dataset_version)
  end

  def editors
    User.where(id: [user_id] + dataset_users.where(role: 'editor').pluck(:user_id))
  end

  def reviewers
    User.where(id: dataset_users.where(role: 'reviewer').select(:user_id))
  end

  def viewers
    User.where(id: [user_id] + dataset_users.where(role: 'viewer').pluck(:user_id))
  end

  def grants_file_access_to?(current_user)
    user_id = (current_user ? current_user.id : nil)
    all_files_public? || (agreements.where(status: 'approved', user_id: user_id).not_expired.count > 0)
  end

  def to_param
    slug
  end

  def self.find_by_param(input)
    find_by_slug(input)
  end

  def folder_name
    Rails.env.test? ? slug : id.to_s
  end

  def root_folder
    File.join(CarrierWave::Uploader::Base.root, 'datasets', folder_name)
  end

  def files_folder
    File.join(root_folder, 'files')
  end

  def reset_index_in_background!(path, recompute: false)
    fork_process(:reset_index!, path, recompute: recompute)
  end

  def reset_index!(params_path, recompute: false)
    full_path = find_file(params_path)
    if full_path && File.directory?(full_path)
      path = full_path.gsub(%r{^#{files_folder}/}, '')
      # FileUtils.mkpath(full_path) # TODO: Potentially add this.
      generate_new_files_in_folder_with_lock(path, recompute: recompute)
    end
  end

  def generate_new_files_in_folder_with_lock(path, recompute: false)
    lock_folder!(path)
    prune_existing_dataset_files(path, recompute: recompute)
    generate_new_files_in_folder(path)
  ensure
    lock_file = File.join(files_folder, path.to_s, '.sleepdata.md5inprogress')
    File.delete(lock_file) if File.exist?(lock_file) && File.file?(lock_file)
  end

  def lock_folder!(location = nil)
    lock_file = File.join(files_folder, location.to_s, '.sleepdata.md5inprogress')
    File.write(lock_file, '')
  end

  def prune_existing_dataset_files(path, recompute: false)
    folder = path.blank? ? '' : "#{path}/"
    dataset_files.where(folder: folder).update_all file_checksum_md5: nil if recompute
    dataset_files.where(folder: folder).find_each(&:verify_file!)
  end

  def non_root_dataset_files
    dataset_files.current.where.not(file_name: '')
  end

  def all_files(path)
    Dir.glob(File.join(files_folder, path.to_s)) + Dir.glob(File.join(files_folder, path.to_s, '*'))
  end

  def generate_new_files_in_folder(path)
    all_files(path).each do |file|
      find_or_create_dataset_file(file)
    end
  end

  def find_or_create_dataset_file(file)
    full_path = file.gsub(%r{^#{files_folder}/}, '')
    file_name = File.basename(full_path)
    folder = full_path.gsub(/#{file_name}$/, '')
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
    lock_file = File.join(files_folder, location.to_s, '.sleepdata.md5inprogress')
    File.exist?(lock_file)
  end

  def file_path(file)
    file.gsub(files_folder + '/', '')
  end

  def find_file_folder(path)
    folders = path.to_s.split('/').collect(&:strip)
    clean_folder_path = nil
    # Navigate to relative folder
    folders.each do |folder|
      dataset_file = dataset_files.current.find_by(full_path: [clean_folder_path, folder].compact.join('/'), is_file: false)
      if dataset_file
        clean_folder_path = [clean_folder_path, dataset_file.file_name].compact.join('/')
      else
        break
      end
    end
    clean_folder_path.to_s
  end

  def find_file(path)
    folders = path.to_s.split('/')[0..-2].collect(&:strip)
    name = path.to_s.split('/').last.to_s.strip
    clean_folder_path = find_file_folder(folders.join('/'))
    entries = Dir.entries(File.join(files_folder, clean_folder_path)).reject { |e| e.first == '.' }
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

  def info_count
    @info_count ||= begin
      count = 0
      count += 1 if info_what.present?
      count += 1 if info_who.present?
      count += 1 if info_when.present?
      count += 1 if info_funded_by.present?
      count
    end
  end

  def create_folders
    FileUtils.mkdir_p files_folder
  end
end
