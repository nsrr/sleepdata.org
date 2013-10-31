class Dataset < ActiveRecord::Base

  mount_uploader :logo, ImageUploader

  # Concerns
  include Deletable

  # Named Scopes
  scope :highlighted, -> { current.where( public: true, slug: ['shhs', 'chat', 'bestair'] ) }

  # Model Validation
  validates_presence_of :name, :slug, :user_id
  validates_uniqueness_of :slug, scope: [ :deleted ]
  validates_format_of :slug, with: /\A[a-z]\w*\Z/i

  # Model Relationships
  belongs_to :user

  def to_param
    slug
  end

  def self.find_by_param(input)
    find_by_slug(input)
  end

  def root_folder
    File.join('carrierwave', 'datasets', 'files', self.id.to_s)
  end

  def files_folder
    File.join( root_folder, 'files' )
  end

  def files(location = nil)
    Dir.glob(File.join(files_folder, location.to_s, '*')).collect{|f| [f.split('/').last, f]}.sort{|a,b| [File.file?(a[1]).to_s, a[0]] <=> [File.file?(b[1]).to_s, b[0]]}
  end

  def file_path(file)
    file.gsub(files_folder + '/', '')
  end

  def find_file(path)
    folders = path.to_s.split('/')[0..-2].collect{|folder| folder.strip}
    file_name = path.to_s.split('/').last.to_s.strip
    clean_folder_path = nil

    # Navigate to relative folder
    folders.each do |folder|
      current_folders = self.files(clean_folder_path).select{|folder_name, f| File.directory?(f)}.collect{|folder_name, f| folder_name}
      if current_folders.index(folder)
        clean_folder_path = [clean_folder_path, current_folders[current_folders.index(folder)]].compact.join('/')
      else
        # "User Input Folder: #{folder} not in allowed folder list: #{current_folders}"
        return nil
      end
    end

    clean_file_name = self.files(clean_folder_path).select{|name, f| File.file?(f) and file_name == name}.collect{|name, f| name}.first

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
      current_user.all_datasets.where(id: self.id).count == 1
    end
  end

  def readme(path)
    File.join(pages_folder, path.to_s)
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

end
