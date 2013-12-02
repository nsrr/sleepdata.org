class Dataset < ActiveRecord::Base

  FILES_PER_PAGE = 100

  mount_uploader :logo, ImageUploader

  # Concerns
  include Deletable

  # Named Scopes
  scope :highlighted, -> { current.where( public: true, slug: ['shhs', 'chat', 'bestair'] ) }
  scope :with_editor, lambda { |arg| where('datasets.user_id IN (?) or datasets.id in (select dataset_users.dataset_id from dataset_users where dataset_users.user_id = ? and dataset_users.editor = ? and dataset_users.approved = ?)', arg, arg, true, true ).references(:dataset_users) }
  scope :with_viewer, lambda { |arg| where('datasets.user_id IN (?) or datasets.public = ? or datasets.id in (select dataset_users.dataset_id from dataset_users where dataset_users.user_id = ? and dataset_users.editor = ? and dataset_users.approved = ?)', arg, true, arg, false, true ).references(:dataset_users) }

  # Model Validation
  validates_presence_of :name, :slug, :user_id
  validates_uniqueness_of :slug, scope: [ :deleted ]
  validates_format_of :slug, with: /\A[a-z]\w*\Z/i

  # Model Relationships
  belongs_to :user
  has_many :dataset_file_audits
  has_many :dataset_page_audits
  has_many :dataset_users

  def viewers
    User.where( id: [self.user_id] + self.dataset_users.where( approved: true ).pluck(:user_id) )
  end

  def editors
    User.where( id: [self.user_id] + self.dataset_users.where( approved: true, editor: true ).pluck(:user_id) )
  end

  def grants_file_access_to?(current_user)
    self.public_files? || ( current_user && self.viewers.pluck(:id).include?(current_user.id) )
  end

  def to_param
    slug
  end

  def self.find_by_param(input)
    find_by_slug(input)
  end

  def root_folder
    File.join(CarrierWave::Uploader::Base.root, 'datasets', (Rails.env.test? ? self.slug : self.id.to_s))
  end

  def files_folder
    File.join( root_folder, 'files' )
  end

  def file_array(f)
    folder = f.gsub(self.files_folder + '/', '')
    file_name = f.split('/').last
    is_file = File.file?(f)
    file_size = File.size(f)
    file_time = File.mtime(f).strftime("%Y-%m-%d %H:%M:%S")

    [folder, file_name, is_file, file_size, file_time]
  end

  def create_folder_index(location = nil)
    FileUtils.mkpath(File.join(files_folder, location.to_s))
    index_file = File.join(files_folder, location.to_s, '.sleepdata.index')
    files = Dir.glob(File.join(files_folder, location.to_s, '*')).sort{|a,b| [File.file?(a).to_s, a.split('/').last] <=> [File.file?(b).to_s, b.split('/').last]}.collect{|f| file_array(f)}
    File.open(index_file, 'w') do |outfile|
      outfile.puts files.size
      files.in_groups_of(FILES_PER_PAGE, false).each do |file_group|
        outfile.puts file_group.to_json
      end
    end
  end

  def reset_folder_indexes
    Dir.glob(File.join(files_folder, '**/.sleepdata.index')).each do |f|
      File.delete(f) if File.exists?(f) and File.file?(f)
    end
  end

  # Returns [[folder, name, is_file, file_size], [...], ... ]
  # index -1 is all files
  # index 0 is the file count
  # index 1 is the first page
  def indexed_files(location = nil, page = 1)
    files = []
    index_file = File.join(files_folder, location.to_s, '.sleepdata.index')

    create_folder_index(location) if not File.exists?(index_file) or Rails.env.test?

    index = 0
    IO.foreach( index_file ) do |line|
      if index == page
        files = if index == 0
          line.to_i
        else
          JSON.parse(line.strip)
        end
        break
      elsif page == -1 and index != 0
        files += JSON.parse(line.strip)
      end
      index += 1
    end

    return files
  end

  def file_path(file)
    file.gsub(files_folder + '/', '')
  end

  def find_file(path)
    folders = path.to_s.split('/')[0..-2].collect{|folder| folder.strip}
    name = path.to_s.split('/').last.to_s.strip
    clean_folder_path = nil

    # Navigate to relative folder
    folders.each do |folder|
      current_folders = self.indexed_files(clean_folder_path, -1).select{|folder, file_name, is_file, file_size, file_time| !is_file}.collect{|folder, file_name, is_file, file_size, file_time| file_name}
      if current_folders.index(folder)
        clean_folder_path = [clean_folder_path, current_folders[current_folders.index(folder)]].compact.join('/')
      else
        # "User Input Folder: #{folder} not in allowed folder list: #{current_folders}"
        return nil
      end
    end

    clean_file_name = self.indexed_files(clean_folder_path, -1).select{|folder, file_name, is_file, file_size, file_time| is_file and file_name == name}.collect{|folder, file_name, is_file, file_size, file_time| file_name}.first

    File.join( files_folder, clean_folder_path.to_s, clean_file_name.to_s )
  end

  def pages_folder
    File.join( root_folder, 'pages' )
  end

  def pages(location = nil)
    Dir.glob(File.join(pages_folder, location.to_s, '*')).collect{|f| [f.split('/').last, f]}.sort{|a,b| [File.file?(a[1]).to_s, a[0]] <=> [File.file?(b[1]).to_s, b[0]]}
  end

  def page_path(page)
    page.gsub(pages_folder + '/', '')
  end

  def editable_by?(current_user)
    @editable_by ||= begin
      self.editors.pluck( :id ).include?(current_user.id)
    end
  end

  # Path can refer to a folder or a file
  def find_page(path)
    folders = path.to_s.split('/')[0..-2].collect{|folder| folder.strip}
    file_name = path.to_s.split('/').last.to_s.strip
    clean_folder_path = nil

    # Navigate to relative folder
    folders.each do |folder|
      current_folders = self.pages(clean_folder_path).select{|folder_name, f| File.directory?(f)}.collect{|folder_name, f| folder_name}
      if current_folders.index(folder)
        clean_folder_path = [clean_folder_path, current_folders[current_folders.index(folder)]].compact.join('/')
      else
        return nil
      end
    end

    clean_file_name = self.pages(clean_folder_path).select{|name, f| file_name == name}.collect{|name, f| name}.first

    File.join( pages_folder, clean_folder_path.to_s, clean_file_name.to_s )
  end



  def color
    colors(Dataset.order(:id).pluck(:id).index(self.id))
  end

  private

    def colors(index)
      colors = ["#bfbf0d", "#9a9cff", "#16a766", "#4986e7", "#cb74e6", "#9f33e6", "#ff7637", "#92e1c0", "#d06c64", "#9fc6e7", "#c2c2c2", "#fa583c", "#AC725E", "#cca6ab", "#b89aff", "#f83b22", "#43d691", "#F691B2", "#a67ae2", "#FFAD46", "#b3dc6c", "#4733e6", "#7dd148"]
      colors[index.to_i % colors.size]
    end

end
