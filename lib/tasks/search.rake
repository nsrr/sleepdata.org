# frozen_string_literal: true

namespace :search do
  desc "Resets search elements in pg_search_documents"
  task reset: :environment do
    PgSearch::Document.delete_all
    Broadcast.find_each(&:update_pg_search_document)
    Reply.find_each(&:update_pg_search_document)
    Topic.find_each(&:update_pg_search_document)
    Tool.find_each(&:update_pg_search_document)
    Variable.find_each(&:update_pg_search_document)
  end
end
