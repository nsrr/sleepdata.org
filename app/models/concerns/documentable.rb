# frozen_string_literal: true

module Documentable
  extend ActiveSupport::Concern

  # included do
  #   scope :current, -> { where deleted: false }
  # end

  # def destroy
  #   update_column :deleted, true
  # end

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

  def find_page_folder(path)
    folders = path.to_s.split('/').collect{|folder| folder.strip}
    clean_folder_path = nil

    folders.each do |folder|
      current_folders = self.pages(clean_folder_path).select{|folder_name, f| File.directory?(f)}.collect{|folder_name, f| folder_name}
      if current_folders.index(folder)
        clean_folder_path = [clean_folder_path, current_folders[current_folders.index(folder)]].compact.join('/')
      else
        break
      end
    end

    return clean_folder_path
  end

  # Path can refer to a folder or a file
  def find_page(path)
    folders = path.to_s.split('/')[0..-2].collect{|folder| folder.strip}
    file_name = path.to_s.split('/').last.to_s.strip

    clean_folder_path = self.find_page_folder(folders.join('/'))

    clean_file_name = self.pages(clean_folder_path).select{|name, f| file_name == name}.collect{|name, f| name}.first

    File.join( pages_folder, clean_folder_path.to_s, clean_file_name.to_s )
  end

end
