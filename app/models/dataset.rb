class Dataset < ActiveRecord::Base

  FILES_PER_PAGE = 100

  mount_uploader :logo, ImageUploader

  # Concerns
  include Deletable, Documentable, Gitable

  # Named Scopes
  scope :highlighted, -> { current.where( public: true, slug: ['shhs', 'chat', 'bestair'] ) }
  scope :release_scheduled, -> { current.where( public: true ).where.not( release_date: nil )}
  scope :with_editor, lambda { |arg| where('datasets.user_id IN (?) or datasets.id in (select dataset_users.dataset_id from dataset_users where dataset_users.user_id = ? and dataset_users.editor = ? and dataset_users.approved = ?)', arg, arg, true, true ).references(:dataset_users) }
  scope :with_viewer, lambda { |arg| where('datasets.user_id IN (?) or datasets.public = ? or datasets.id in (select dataset_users.dataset_id from dataset_users where dataset_users.user_id = ? and dataset_users.approved = ?)', arg, true, arg, true ).references(:dataset_users) }

  # Model Validation
  validates_presence_of :name, :slug, :user_id
  validates_uniqueness_of :slug, scope: [ :deleted ]
  validates_format_of :slug, with: /\A[a-z][a-z0-9\-]*\Z/

  # Model Relationships
  belongs_to :user
  has_many :dataset_file_audits
  has_many :dataset_page_audits
  has_many :dataset_users
  has_many :domains
  has_many :forms
  has_many :variables
  has_many :variable_forms
  has_many :dataset_contributors
  has_many :contributors, -> { where deleted: false }, through: :dataset_contributors, source: :user

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

    # Return if the folder does not exist
    unless File.directory?(File.join(files_folder, location.to_s))
      return (page == 0 ? 0 : files)
    end

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

  def total_file_count(location = nil)
    # Dir.glob(File.join(files_folder, '**', '*')).select { |file| File.file?(file) }.count
    file_count = 0

    index_files = Dir.glob(File.join(files_folder, location.to_s, '**', '.sleepdata.index'))

    return 0 if index_files.count == 0

    index_files.each do |index_file|
      IO.foreach( index_file ) do |line|
        file_count += line.to_i
        break
      end
    end

    file_count - (index_files.count - 1)
  end

  def folder_has_files?(location)
    self.indexed_files(location, -1).select{|folder, file_name, is_file, file_size, file_time| is_file}.count > 0
  end

  def file_path(file)
    file.gsub(files_folder + '/', '')
  end

  def find_file_folder(path)
    folders = path.to_s.split('/').collect{|folder| folder.strip}
    clean_folder_path = nil

    # Navigate to relative folder
    folders.each do |folder|
      current_folders = self.indexed_files(clean_folder_path, -1).select{|folder, file_name, is_file, file_size, file_time| !is_file}.collect{|folder, file_name, is_file, file_size, file_time| file_name}
      if current_folders.index(folder)
        clean_folder_path = [clean_folder_path, current_folders[current_folders.index(folder)]].compact.join('/')
      else
        break
      end
    end

    return clean_folder_path
  end

  def find_file(path)
    folders = path.to_s.split('/')[0..-2].collect{|folder| folder.strip}
    name = path.to_s.split('/').last.to_s.strip

    clean_folder_path = self.find_file_folder(folders.join('/'))

    clean_file_name = self.indexed_files(clean_folder_path, -1).select{|folder, file_name, is_file, file_size, file_time| is_file and file_name == name}.collect{|folder, file_name, is_file, file_size, file_time| file_name}.first

    File.join( files_folder, clean_folder_path.to_s, clean_file_name.to_s )
  end

  def color
    colors(Dataset.order(:id).pluck(:id).index(self.id))
  end

  def load_data_dictionary!
    version = File.open("#{self.root_folder}/dd/VERSION", &:readline).strip rescue version = nil
    form_files = Dir.glob("#{self.root_folder}/dd/forms/**/*.json", File::FNM_CASEFOLD)
    domain_files = Dir.glob("#{self.root_folder}/dd/domains/**/*.json", File::FNM_CASEFOLD)
    variable_files = Dir.glob("#{self.root_folder}/dd/variables/**/*.json", File::FNM_CASEFOLD)
    self.variables.delete_all
    self.forms.delete_all
    self.variable_forms.delete_all
    self.domains.delete_all
    form_files.each do |json_file|
      if json = JSON.parse(File.read(json_file)) rescue false
        path = json_file.gsub("#{self.root_folder}/dd/forms/", '')
        name = path.split('/')[-1].to_s.gsub(/\.json$/, '')
        folder = path.split('/')[0..-2].join('/')
        display_name = json['display_name']
        code_book = json['code_book']
        self.forms.create( folder: folder, name: name, display_name: display_name, code_book: code_book, version: version )
      end
    end
    domain_files.each do |json_file|
      if json = JSON.parse(File.read(json_file)) rescue false
        path = json_file.gsub("#{self.root_folder}/dd/domains/", '')
        name = path.split('/')[-1].to_s.gsub(/\.json$/, '')
        folder = path.split('/')[0..-2].join('/')
        self.domains.create( folder: folder, name: name, options: json, version: version )
      end
    end
    variable_files.each do |json_file|
      if json = JSON.parse(File.read(json_file)) rescue false
        path = json_file.gsub("#{self.root_folder}/dd/variables/", '')
        name = path.split('/')[-1].to_s.gsub(/\.json$/, '')
        folder = path.split('/')[0..-2].join('/')
        domain = self.domains.find_by_name(json['domain'])
        search_terms = [name.downcase] + folder.split('/')
        search_terms += (json['labels'] || [])
        search_terms += (json['forms'] || [])
        [json['display_name'], json['units'], json['calculation'], json['description']].each do |json_string|
          search_terms += json_string.to_s.split(/[^\w\d%]/)
        end

        v = self.variables.create(
          folder: folder,
          name: name,
          display_name: json['display_name'],
          description: json['description'],
          variable_type: json['type'],
          units: json['units'],
          calculation: json['calculation'],
          commonly_used: (json['commonly_used'] == true),
          domain_id: (domain ? domain.id : nil),
          version: version,
          search_terms: search_terms.select{|a| a.to_s.strip.size > 1}.collect{|b| b.downcase.strip}.uniq.sort.join(' ')
        )
        unless v.new_record?
          self.forms.where( name: (json['forms'] || []) ).each do |form|
            v.forms << form
          end
        end
      end
    end
  end

  def create_page_audit!(current_user, page_path, remote_ip )
    self.dataset_page_audits.create( user_id: (current_user ? current_user.id : nil), page_path: page_path, remote_ip: remote_ip )
  end

  private

    def colors(index)
      colors = ["#bfbf0d", "#9a9cff", "#16a766", "#4986e7", "#cb74e6", "#9f33e6", "#ff7637", "#92e1c0", "#d06c64", "#9fc6e7", "#c2c2c2", "#fa583c", "#AC725E", "#cca6ab", "#b89aff", "#f83b22", "#43d691", "#F691B2", "#a67ae2", "#FFAD46", "#b3dc6c", "#4733e6", "#7dd148"]
      colors[index.to_i % colors.size]
    end

end
