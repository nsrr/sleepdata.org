# frozen_string_literal: true

# Allows admins to create and edit folders.
class Admin::FoldersController < ApplicationController
  before_action :authenticate_user!
  before_action :check_admin
  before_action :find_folder_or_redirect, only: [:show, :edit, :update, :destroy]

  layout "layouts/full_page_sidebar"

  # GET /folders
  def index
    scope = Folder.current.search(params[:search], match_start: false)
    @folders = scope_order(scope).page(params[:folder]).per(40)
  end

  # # GET /folders/1
  # def show
  # end

  # GET /folders/new
  def new
    @folder = Folder.new
  end

  # # GET /folders/1/edit
  # def edit
  # end

  # POST /folders
  def create
    @folder = Folder.new(folder_params)

    if @folder.save
      redirect_to admin_folder_path(@folder), notice: "Folder was successfully created."
    else
      render :new
    end
  end

  # PATCH /folders/1
  def update
    if @folder.update(folder_params)
      redirect_to admin_folder_path(@folder), notice: "Folder was successfully updated."
    else
      render :edit
    end
  end

  # DELETE /folders/1
  def destroy
    @folder.destroy
    redirect_to admin_folders_path, notice: "Folder was successfully deleted."
  end

  private

  def find_folder_or_redirect
    @folder = Folder.current.find_by_slug(params[:id])
    redirect_without_folder
  end

  def redirect_without_folder
    empty_response_or_root_path(admin_folders_path) unless @folder
  end

  # Only allow a list of trusted parameters through.
  def folder_params
    params.require(:folder).permit(:name, :slug, :position, :displayed)
  end

  def scope_order(scope)
    @order = params[:order]
    scope.order(Arel.sql(Folder::ORDERS[params[:order]] || Folder::DEFAULT_ORDER))
  end
end
