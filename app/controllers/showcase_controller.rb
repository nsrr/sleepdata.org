# frozen_string_literal: true

# Provides several pages that showcase different aspects of the NSRR.
class ShowcaseController < ApplicationController
  # # GET /showcase
  # def index
  # end

  def show
    if showcases.include? params[:slug]
      render params[:slug].tr("-", "_")
    else
      redirect_to showcase_path
    end
  end

  private

  def showcases
    %w(search-nsrr where-to-start)
  end
end
