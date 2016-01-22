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
  has_many :public_files, source: :dataset
  has_many :requests
  has_many :agreements, -> { where deleted: false }, through: :requests

  def public_file?(path)
    public_files.where(file_path: file_path(path)).count > 0
  end

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

  def create_folder_index(location = nil)
    index_file = File.join(files_folder, location.to_s, '.sleepdata.index')
    lock_file = File.join(files_folder, location.to_s, '.sleepdata.md5inprogress')
    begin
      File.delete(index_file) if File.exist?(index_file) && File.file?(index_file)
      FileUtils.mkpath(File.join(files_folder, location.to_s))
      File.write(lock_file, "#{Time.zone.now}: Refresh started\n")
      files = Dir.glob(File.join(files_folder, location.to_s, '*'))
              .sort { |a, b| [File.file?(a).to_s, a.split('/').last] <=> [File.file?(b).to_s, b.split('/').last] }
              .collect { |f| file_array(f, lock_file) }
      File.open(index_file, 'w') do |outfile|
        outfile.puts files.size
        files.in_groups_of(FILES_PER_PAGE, false).each do |file_group|
          outfile.puts file_group.to_json
        end
      end
    ensure
      File.delete(lock_file) if File.exist?(lock_file) && File.file?(lock_file)
    end
  end

  def reset_folder_indexes
    Dir.glob(File.join(files_folder, '**/.sleepdata.index')).each do |f|
      File.delete(f) if File.exist?(f) && File.file?(f)
    end
  end

  def current_folder_locked?(location)
    lock_file = File.join(files_folder, location.to_s, '.sleepdata.md5inprogress')
    File.exist?(lock_file)
  end

  # Returns [[folder, file_name, is_file, file_size, file_time, file_digest], [...], ... ]
  # index -1 is all files
  # index 0 is the file count
  # index 1 is the first page
  def indexed_files(location = nil, page = 1)
    files = []
    index_file = File.join(files_folder, location.to_s, '.sleepdata.index')
    # Return if the folder does not exist
    unless File.directory?(File.join(files_folder, location.to_s))
      return (page == 0 ? 0 : files)
    end
    if Rails.env.test?
      create_folder_index(location)
    elsif !File.exist?(index_file)
      return (page == 0 ? 0 : files)
    end
    index = 0
    IO.foreach(index_file) do |line|
      if index == page
        files = if index == 0
                  line.to_i
                else
                  JSON.parse(line.strip)
                end
        break
      elsif page == -1 && index != 0
        files += JSON.parse(line.strip)
      end
      index += 1
    end
    files = files.count if page == 0 && files.is_a?(Array)
    files
  end

  def total_file_count(location = nil)
    file_count = 0
    index_files = Dir.glob(File.join(files_folder, location.to_s, '**', '.sleepdata.index'))
    return 0 if index_files.count == 0
    index_files.each do |index_file|
      IO.foreach(index_file) do |line|
        file_count += line.to_i
        break
      end
    end
    file_count - (index_files.count - 1)
  end

  def count_total_file_size
    files = []
    index_files = Dir.glob(File.join(files_folder, '**', '.sleepdata.index'))
    return 0 if index_files.count == 0
    index_files.each do |index_file|
      index = 0
      IO.foreach(index_file) do |line|
        if index != 0
          files += JSON.parse(line.strip).select { |f| f[2] }.collect { |f| f[3] }
        end
        index += 1
      end
    end
    files.sum
  end

  def folder_has_files?(location)
    indexed_files(location, -1).count { |_folder, _file_name, is_file, _file_size, _file_time| is_file } > 0
  end

  def file_path(file)
    file.gsub(files_folder + '/', '')
  end

  def find_file_folder(path)
    folders = path.to_s.split('/').collect(&:strip)
    clean_folder_path = nil
    # Navigate to relative folder
    folders.each do |folder|
      current_folders = indexed_files(clean_folder_path, -1)
                        .select { |_folder, _file_name, is_file, _file_size, _file_time| !is_file }
                        .collect { |_folder, file_name, _is_file, _file_size, _file_time| file_name }
      if current_folders.index(folder)
        clean_folder_path = [clean_folder_path, current_folders[current_folders.index(folder)]].compact.join('/')
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
    clean_file_name = indexed_files(clean_folder_path, -1)
                      .select { |_folder, file_name, is_file, _file_size, _file_time| is_file && file_name == name }
                      .collect { |_folder, file_name, _is_file, _file_size, _file_time| file_name }.first
    File.join(files_folder, clean_folder_path.to_s, clean_file_name.to_s)
  end

  def color
    colors(Dataset.order(:id).pluck(:id).index(id))
  end

  def recompute_datasets_folder_indices_in_background(folders)
    fork_process(:recompute_datasets_folder_indices, folders)
  end

  def recompute_datasets_folder_indices(folders)
    lock_folder!(nil)
    create_folder_index(nil)
    folders.each do |folder|
      if File.exist?(File.join(files_folder, folder))
        lock_folder!(folder)
        create_folder_index(folder)
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

  private

  def colors(index)
    colors = %w(#bfbf0d #9a9cff #16a766 #4986e7 #cb74e6 #9f33e6 #ff7637 #92e1c0
                #d06c64 #9fc6e7 #c2c2c2 #fa583c #AC725E #cca6ab #b89aff #f83b22
                #43d691 #F691B2 #a67ae2 #FFAD46 #b3dc6c #4733e6 #7dd148)
    colors[index.to_i % colors.size]
  end
end
