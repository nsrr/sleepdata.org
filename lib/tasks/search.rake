# frozen_string_literal: true

namespace :search do
  desc "Resets search elements in pg_search_documents"
  task reset: :environment do
    print "Clearing cache..."
    PgSearch::Document.delete_all
    puts "DONE".white
    print "Reindexing dataset pages..."
    DatasetPage.find_each(&:update_pg_search_document)
    puts "DONE".white
    print "Reindexing articles..."
    Broadcast.find_each(&:update_pg_search_document)
    puts "DONE".white
    print "Reindexing replies..."
    Reply.find_each(&:update_pg_search_document)
    puts "DONE".white
    print "Reindexing topics..."
    Topic.find_each(&:update_pg_search_document)
    puts "DONE".white
    print "Reindexing variables..."
    Variable.find_each(&:update_pg_search_document)
    puts "DONE".white
  end

  desc "Pulls dataset documentation pages into the database"
  task index_dataset_pages: :environment do
    Dataset.released.each do |dataset|
      index_folder(dataset, nil)
    end
  end
end

def index_folder(dataset, folder)
  dataset.pages(folder).each do |folder, page_path|
    if File.file?(page_path)
      contents = File.read(page_path)
      page_path.gsub!(dataset.pages_folder + "/", "")
      puts "          #{page_path}"
      search_terms = page_path.split("/")
      search_terms += page_path.split(/[^\w]/)
      dataset.dataset_pages.where(page_path: page_path).first_or_create
        .update(contents: contents, search_terms: search_terms.join(" "))
    else
      puts "Indexing: #{folder}"
      index_folder(dataset, folder)
    end
  end
end
