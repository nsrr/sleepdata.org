# frozen_string_literal: true

# Allows users to view dataset documentation and download files
class DatasetsController < ApplicationController
  before_action :authenticate_user_from_token!, only: [
    :show, :json_manifest, :files, :editor, :index
  ]
  before_action :find_viewable_dataset_or_redirect, only: [
    :show, :json_manifest, :files, :access, :editor, :logo, :images,
    :pages, :search, :folder_progress
  ]
  before_action :find_dataset_file, only: [:files, :access, :json_manifest]

  # Concerns
  include Pageable

  # Returns if the user is an editor
  def editor
    editor = (current_user && @dataset.editable_by?(current_user) ? true : false)
    render json: { editor: editor, user_id: (current_user ? current_user.id : nil) }
  end

  # GET /datasets/1/search
  def search
    @term = params[:s].to_s.gsub(/[^\w]/, "")
    @results = []
    @results = `grep -i -R #{@term} #{@dataset.pages_folder}`.split("\n") unless @term.blank?
  end

  # GET /datasets/1/json_manifest
  def json_manifest
    path = @dataset.find_file_folder(params[:path])
    if path == params[:path].to_s
      folder = path.blank? ? "" : "#{path}/"
      @dataset_files = @dataset.non_root_dataset_files.where(folder: folder).order_by_type
    else
      render json: []
    end
  end

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
      @root_dataset_file = @dataset.dataset_files.find_by(full_path: path.to_s)
      current_user ? store_external_location_in_session : store_internal_location_in_session
      render :files
    else
      redirect_to files_dataset_path(@dataset, path: @dataset.find_file_folder(params[:path]))
    end
  end

  # Get /datasets/access/*path
  def access
    result = (@dataset_file && @dataset_file.is_file? && @dataset_file.file_exist? && @dataset_file.downloadable_by_user?(current_user) ? true : false)
    render json: { dataset_id: @dataset.id, result: result, path: @dataset_file.full_path }
  end

  # GET /datasets
  # GET /datasets.json
  def index
    @order = scrub_order(Dataset, params[:order], "release_date, name")
    dataset_scope = if current_user
                      current_user.all_viewable_datasets
                    else
                      Dataset.released
                    end
    if params[:ages]
      (min_age, max_age) = params[:ages].split("-").collect { |s| parse_integer(s) }
      dataset_scope = dataset_scope.where("age_min <= ?", max_age) if max_age.present?
      dataset_scope = dataset_scope.where("age_max >= ?", min_age) if min_age.present?
    end
    dataset_scope = dataset_scope.where(polysomnography: true) if params[:data] == "polysomnography"
    dataset_scope = dataset_scope.where(actigraphy: true) if params[:data] == "actigraphy"
    @datasets = dataset_scope.order(@order).page(params[:page]).per(24)
  end

  # # GET /datasets/1
  # # GET /datasets/1.json
  # def show
  # end

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
end
