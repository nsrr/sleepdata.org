# frozen_string_literal: true

# Allows users to view pages.
class PagesController < ApplicationController
  before_action :find_page_or_redirect, only: [:show]

  # # GET /pages/:slug
  # def show
  # end

  private

  def find_page_or_redirect
    @page = Page.current.find_by_slug(params[:id])
    redirect_without_page
  end

  def redirect_without_page
    empty_response_or_root_path(root_path) unless @page
  end
end
