# frozen_string_literal: true

class Dataset < ApplicationRecord
  FILES_PER_PAGE = 100

  mount_uploader :logo, ImageUploader

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
  validates :info_size, numericality: { greater_than_or_equal_to: 0 }

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
  has_many :dataset_contributors
  has_many :contributors, -> { where deleted: false }, through: :dataset_contributors, source: :user
  has_many :requests
  has_many :agreements, -> { where deleted: false }, through: :requests

  has_many :dataset_files

  def chartable_variables
    variables.order(:folder, :name)
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
    all_files_public? || (agreements.where(status: 'approved', user_id: (current_user ? current_user.id : nil)).not_expired.count > 0)
  end

  def to_param
    slug
  end

  def self.find_by_param(input)
    find_by_slug(input)
  end

  def root_folder
    File.join(CarrierWave::Uploader::Base.root, 'datasets', (Rails.env.test? ? slug : id.to_s))
  end

  def files_folder
    File.join(root_folder, 'files')
  end

  def file_array(f, lock_file)
    folder = f.gsub(%r{^#{files_folder}/}, '')
    file_name = f.split('/').last
    is_file = File.file?(f)
    file_size = File.size(f)
    file_time = File.mtime(f).strftime('%Y-%m-%d %H:%M:%S')
    file_digest = if is_file
                    message = "Computing MD5 Digest for #{file_name} of size #{file_size} bytes"
                    File.open(lock_file, 'a') { |f| f.write "#{Time.zone.now}: #{message}\n" } if file_size > 10.megabytes
                    Digest::MD5.file(f).hexdigest
                  end
    [folder, file_name, is_file, file_size, file_time, file_digest]
  end

  def lock_folder!(location = nil)
    lock_file = File.join(files_folder, location.to_s, '.sleepdata.md5inprogress')
    File.write(lock_file, '')
  end

  def reset_index_in_background!(path)
    fork_process(:reset_index!, path)
  end

  def reset_index!(params_path)
    full_path = find_file(params_path)
    if full_path && File.directory?(full_path)
      path = full_path.gsub(%r{^#{files_folder}/}, '')
      # FileUtils.mkpath(full_path) # TODO: Potentially add this.
      generate_new_files_in_folder_with_lock(path)
    end
  end

  def generate_new_files_in_folder_with_lock(path)
    lock_folder!(path)
    generate_new_files_in_folder(path)
  ensure
    lock_file = File.join(files_folder, path.to_s, '.sleepdata.md5inprogress')
    File.delete(lock_file) if File.exist?(lock_file) && File.file?(lock_file)
  end

  def generate_new_files_in_folder(path)
    folder = path.blank? ? '' : "#{path}/"
    dataset_files.current.where(folder: folder).find_each do |dataset_file|
      dataset_file.destroy unless dataset_file.file_exist?
    end
    Dir.glob(File.join(files_folder, path.to_s, '*')).each do |file|
      find_or_create_dataset_file(file)
    end
  end

  def find_or_create_dataset_file(file)
    full_path = file.gsub(%r{^#{files_folder}/}, '')
    file_name = file.split('/').last
    folder = full_path.gsub(/#{file_name}$/, '')
    file_size = File.size(file)
    file_time = File.mtime(file)
    is_file = File.file?(file)
    if is_file
      file_checksum_md5 = Digest::MD5.file(file).hexdigest
      checksum_md5_generated_at = Time.zone.now
    else
      file_checksum_md5 = nil
      checksum_md5_generated_at = nil
    end
    dataset_file = dataset_files.where(full_path: full_path, is_file: is_file)
                                .first_or_create(
                                  folder: folder, file_name: file_name,
                                  file_size: file_size, file_time: file_time
                                )
    dataset_file.update(
      folder: folder, file_name: file_name, file_size: file_size,
      file_time: file_time, file_checksum_md5: file_checksum_md5,
      checksum_md5_generated_at: checksum_md5_generated_at, deleted: false
    )
    # These are set elsewhere and shouldn't be overwritten
    # :publicly_available, :archived
  end

  # def create_folder_index(location = nil)
  #   index_file = File.join(files_folder, location.to_s, '.sleepdata.index')
  #   lock_file = File.join(files_folder, location.to_s, '.sleepdata.md5inprogress')
  #   begin
  #     File.delete(index_file) if File.exist?(index_file) && File.file?(index_file)
  #     FileUtils.mkpath(File.join(files_folder, location.to_s))
  #     File.write(lock_file, "#{Time.zone.now}: Refresh started\n")
  #     files = Dir.glob(File.join(files_folder, location.to_s, '*'))
  #             .sort { |a, b| [File.file?(a).to_s, a.split('/').last] <=> [File.file?(b).to_s, b.split('/').last] }
  #             .collect { |f| file_array(f, lock_file) }
  #     File.open(index_file, 'w') do |outfile|
  #       outfile.puts files.size
  #       files.in_groups_of(FILES_PER_PAGE, false).each do |file_group|
  #         outfile.puts file_group.to_json
  #       end
  #     end
  #   ensure
  #     File.delete(lock_file) if File.exist?(lock_file) && File.file?(lock_file)
  #   end
  # end

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
      dataset_file = dataset_files.find_by(full_path: [clean_folder_path, folder].compact.join('/'), is_file: false)
      if dataset_file
        clean_folder_path = [clean_folder_path, dataset_file.file_name].compact.join('/')
      else
        break
      end
    end
    clean_folder_path
  end

  def find_file(path)
    folders = path.to_s.split('/')[0..-2].collect(&:strip)
    name = path.to_s.split('/').last.to_s.strip
    clean_folder_path = find_file_folder(folders.join('/'))
    entries = Dir.entries(File.join(files_folder, clean_folder_path.to_s)).reject { |e| e.first == '.' }
    clean_file_name = entries.find { |e| e == name }
    File.join(files_folder, clean_folder_path.to_s, clean_file_name.to_s)
  end

  def recompute_datasets_folder_indices_in_background(folders)
    fork_process(:recompute_datasets_folder_indices, folders)
  end

  def recompute_datasets_folder_indices(folders)
    reset_index!(nil)
    folders.each do |folder|
      if File.exist?(File.join(files_folder, folder))
        reset_index!(folder)
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
end
