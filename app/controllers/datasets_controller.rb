# frozen_string_literal: true

# Allows users to view dataset documentation and download files
class DatasetsController < ApplicationController
  before_action :authenticate_user_from_token!, only: [
    :show, :files, :editor, :index
  ]
  before_action :find_viewable_dataset_or_redirect, only: [
    :show, :files, :access, :editor, :logo, :images,
    :pages, :search, :folder_progress
  ]
  before_action :find_dataset_file, only: [:files, :access]

  # Concerns
  include Pageable

  # GET /datasets/1/a/:auth_token/editor.json
  # def editor
  # end

  def logo
    send_file_if_present @dataset.logo
  end

  def folder_progress
    path = params[:path]
    folder = path.blank? ? "" : "#{path}/"
    @dataset_files = @dataset.non_root_dataset_files.where(folder: folder).order_by_type.page(params[:page]).per(100)
  end

  def files
    if @dataset_file && @dataset_file.is_file? && @dataset_file.file_exist? && @dataset_file.downloadable_by_user?(current_user)
      @dataset.dataset_file_audits.create(
        user_id: (current_user ? current_user.id : nil),
        file_path: @dataset_file.full_path,
        medium: params[:medium],
        file_size: @dataset_file.file_size,
        remote_ip: request.remote_ip
      )
      if params[:inline] == "1" && @dataset_file.pdf?
        send_file @dataset_file.filesystem_path, type: "application/pdf", disposition: "inline"
      elsif params[:preview] == "1" && (@dataset_file.md? || @dataset_file.pdf? || @dataset_file.image?)
        render "dataset_files/show", formats: :html
      else
        send_file @dataset_file.filesystem_path
      end
    elsif (@dataset_file && !@dataset_file.is_file?) || params[:path].blank?
      path = params[:path]
      folder = path.blank? ? "" : "#{path}/"
      @dataset_files = @dataset.non_root_dataset_files.where(folder: folder).order_by_type.page(params[:page]).per(100)
      current_user ? store_external_location_in_session : store_internal_location_in_session
      render :files
    else
      redirect_to files_dataset_path(@dataset, path: @dataset.find_file_folder(params[:path]))
    end
  end

  # This command is used by altamira to determine if the user has permission to
  # access to the specified file.
  # GET /datasets/1/access/*path
  def access
    result = (@dataset_file && @dataset_file.is_file? && @dataset_file.file_exist? && @dataset_file.downloadable_by_user?(current_user) ? true : false)
    render json: { dataset_id: @dataset.id, result: result, path: @dataset_file&.full_path }
  end

  # GET /datasets
  def index
    scope = current_user ? current_user.all_viewable_datasets : Dataset.released
    if params[:ages]
      (min_age, max_age) = params[:ages].split("-").collect { |s| parse_integer(s) }
      scope = scope.where("age_min <= ?", max_age) if max_age.present?
      scope = scope.where("age_max >= ?", min_age) if min_age.present?
    end
    scope = scope.where(polysomnography: true) if params[:data] == "polysomnography"
    scope = scope.where(actigraphy: true) if params[:data] == "actigraphy"
    @datasets = scope_order(scope).page(params[:page]).per(25)
  end

  # GET /datasets/1
  def show
    render layout: "layouts/full_page"
  end

  private

  def find_viewable_dataset_or_redirect
    super(:id)
  end

  def find_dataset_file
    @dataset_file = @dataset.dataset_files.current.find_by(full_path: params[:path])
  end

  def parse_integer(string)
    Integer(format("%d", string))
  rescue
    nil
  end

  def scope_order(scope)
    @order = params[:order]
    scope.order(Arel.sql(Dataset::ORDERS[params[:order]] || Dataset::DEFAULT_ORDER))
  end
end
