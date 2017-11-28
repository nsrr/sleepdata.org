# frozen_string_literal: true

# Allows organization owners and editors to view and generate data request exports.
class ExportsController < ApplicationController
  before_action :authenticate_user!
  # TODO: Change to only be for organization owners.
  before_action :check_system_admin
  before_action :find_export_or_redirect, only: [
    :show, :download, :edit, :update, :destroy
  ]

  # GET /exports
  def index
    @exports = current_user.exports.order(id: :desc).page(params[:page]).per(20)
  end

  # # GET /exports/1
  # def show
  # end

  # GET /exports/:id/download
  def download
    send_file_if_present @export.zipped_file
  end

  # GET /exports/new
  def new
    @export = current_user.exports.new
  end

  # # GET /exports/1/edit
  # def edit
  # end

  # POST /exports
  def create
    @export = current_user.exports.new(export_params)
    if @export.save
      redirect_to @export, notice: "Export was successfully created."
    else
      render :new
    end
  end

  # PATCH /exports/1
  def update
    if @export.update(export_params)
      redirect_to @export, notice: "Export was successfully updated."
    else
      render :edit
    end
  end

  # DELETE /exports/1
  def destroy
    @export.destroy
    redirect_to exports_path, notice: "Export was successfully deleted."
  end

  private

  def find_export_or_redirect
    @export = current_user.exports.find_by(id: params[:id])
    empty_response_or_root_path(exports_path) unless @export
  end

  def export_params
    params.require(:export).permit(:name, :organization_id)
  end
end
