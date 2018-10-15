# frozen_string_literal: true

# Track most common searches.
class Search < ApplicationRecord
  ORDERS = {
    "searches" => "searches.search_count",
    "searches desc" => "searches.search_count desc",
    "results" => "searches.results_count",
    "results desc" => "searches.results_count desc"
  }
  DEFAULT_ORDER = "searches.search_count desc"
end
