# frozen_string_literal: true

# Provides back search results from across the NSRR.
class SearchController < ApplicationController
  def index
    @search = params[:search].to_s.downcase.split(/[^\w]/).reject(&:blank?).uniq.join(' & ')
    @search_documents = PgSearch.multisearch(params[:search]).page(params[:page]).per(10)
  end
end
