# frozen_string_literal: true

# Allows admins to create and edit pages.
class Admin::PagesController < ApplicationController
  before_action :authenticate_user!
  before_action :check_admin
  before_action :find_page_or_redirect, only: [:show, :edit, :update, :destroy]

  layout "layouts/full_page_sidebar"

  # GET /pages
  def index
    scope = Page.current.search(params[:search], match_start: false)
    @pages = scope_order(scope).page(params[:page]).per(40)
  end

  # # GET /pages/1
  # def show
  # end

  # GET /pages/new
  def new
    @page = Page.new
  end

  # # GET /pages/1/edit
  # def edit
  # end

  # POST /pages
  def create
    @page = Page.new(page_params)

    if @page.save
      redirect_to admin_page_path(@page), notice: "Page was successfully created."
    else
      render :new
    end
  end

  # PATCH /pages/1
  def update
    if @page.update(page_params)
      redirect_to admin_page_path(@page), notice: "Page was successfully updated."
    else
      render :edit
    end
  end

  # DELETE /pages/1
  def destroy
    @page.destroy
    redirect_to admin_pages_path, notice: "Page was successfully deleted."
  end

  private

  def find_page_or_redirect
    @page = Page.current.find_by_slug(params[:id])
    redirect_without_page
  end

  def redirect_without_page
    empty_response_or_root_path(admin_pages_path) unless @page
  end

  # Only allow a list of trusted parameters through.
  def page_params
    params.require(:page).permit(:slug, :title, :description)
  end

  def scope_order(scope)
    @order = params[:order]
    scope.order(Arel.sql(Page::ORDERS[params[:order]] || Page::DEFAULT_ORDER))
  end
end
