# frozen_string_literal: true

namespace :search do
  desc "Resets search elements in pg_search_documents"
  task reset: :environment do
    print "Clearing cache..."
    PgSearch::Document.delete_all
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
end
