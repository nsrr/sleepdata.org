# frozen_string_literal: true

# Provides back search results from across the NSRR.
class SearchController < ApplicationController
  def index
    clean_search = params[:search].to_s.squish.downcase
    @search = clean_search.split(/[^\w]/).reject(&:blank?).uniq.join(" & ")
    scope = PgSearch.multisearch(params[:search])

    @all_count = scope.count
    @forum_count = scope.where(searchable_type: ["Topic", "Reply"]).count
    @blog_count = scope.where(searchable_type: "Broadcast").count
    @variables_count = scope.where(searchable_type: "Variable").count
    @datasets_count = scope.where(searchable_type: "DatasetPage").count

    case params[:from]
    when "forum"
      scope = scope.where(searchable_type: ["Topic", "Reply"])
    when "blog"
      scope = scope.where(searchable_type: "Broadcast")
    when "variables"
      scope = scope.where(searchable_type: "Variable")
    when "datasets"
      scope = scope.where(searchable_type: "DatasetPage")
    end

    @search_documents = scope.page(params[:page]).per(25)
    if clean_search.present? && params[:page].blank?
      search = Search.where(search: clean_search).first_or_create
      search.update results_count: @search_documents.total_count
      search.increment! :search_count
    end

    viewable_datasets = if current_user
                          current_user.all_viewable_datasets
                        else
                          Dataset.released
                        end
    @dataset = viewable_datasets.where("datasets.name = ? or datasets.slug = ?", clean_search, clean_search).first
  end
end
