# frozen_string_literal: true

# Provides back search results from across the NSRR.
class SearchController < ApplicationController
  def index
    clean_search = params[:search].to_s.squish.downcase
    @search = clean_search.split(/[^\w]/).reject(&:blank?).uniq.join(" & ")
    scope = PgSearch.multisearch(params[:search])
    scope = scope.where(searchable_type: ["Topic", "Reply"]) if params[:from] == "forum"
    @search_documents = scope.page(params[:page]).per(10)
    if clean_search.present? && params[:page].blank?
      search = Search.where(search: clean_search).first_or_create
      search.update results_count: @search_documents.total_count
      search.increment! :search_count
    end
  end
end
