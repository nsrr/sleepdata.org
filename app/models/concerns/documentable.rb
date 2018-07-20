# frozen_string_literal: true

# Allows datasets to be have nested documentation.
module Documentable
  extend ActiveSupport::Concern

  def pages_folder
    File.join(root_folder, "pages")
  end

  def pages(location = nil)
    Dir.glob(File.join(pages_folder, location.to_s, "*"))
       .collect { |f| [f.split("/").last, f] }
       .sort { |a, b| [File.file?(a[1]).to_s, a[0]] <=> [File.file?(b[1]).to_s, b[0]] }
  end

  def page_path(page)
    page.gsub("#{pages_folder}/", "")
  end

  def find_page_folder(path)
    folders = path.to_s.split("/").collect(&:strip)
    clean_folder_path = nil
    folders.each do |folder|
      current_folders = pages(clean_folder_path).select { |_folder_name, f| File.directory?(f) }.collect(&:first)
      break unless current_folders.index(folder)
      clean_folder_path = [clean_folder_path, current_folders[current_folders.index(folder)]].compact.join("/")
    end
    clean_folder_path
  end

  # Path can refer to a folder or a file
  def find_page(path)
    folders = path.to_s.split("/")[0..-2].collect(&:strip)
    file_name = path.to_s.split("/").last.to_s.strip
    clean_folder_path = find_page_folder(folders.join("/"))
    clean_file_name = pages(clean_folder_path).select { |name, _| file_name == name }.collect(&:first).first
    File.join(pages_folder, clean_folder_path.to_s, clean_file_name.to_s)
  end
end
