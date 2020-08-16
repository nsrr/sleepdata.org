# frozen_string_literal: true

# Allows dataset editors to manage individual datasets.
class Editor::DatasetsController < ApplicationController
  before_action :authenticate_user!
  before_action :check_organization_editor, only: [:new, :create]
  before_action :find_editable_dataset_or_redirect, except: [:new, :create]

  layout "layouts/full_page_sidebar"

  # Concerns
  include Pageable

  # GET /datasets/1/data_requests
  def data_requests
    scope = @dataset.data_requests
    scope = scope.where(status: params[:status]) if params[:status].present?
    @data_requests = scope_order(scope).page(params[:page]).per(40)
  end

  # GET /datasets/1/audits
  def audits
    audit_scope = @dataset.dataset_file_audits.order(id: :desc)
    audit_scope = audit_scope.where(user_id: params[:user_id].blank? ? nil : params[:user_id]) if params.key?(:user_id)
    audit_scope = audit_scope.where(medium: params[:medium].blank? ? nil : params[:medium]) if params.key?(:medium)
    audit_scope = audit_scope.where(remote_ip: params[:remote_ip].blank? ? nil : params[:remote_ip]) if params.key?(:remote_ip)
    @audits = audit_scope.includes(:user).page(params[:page]).per(100)
  end

  # # GET /datasets/1/collaborators
  # def collaborators
  # end

  # GET /datasets/1/page-views
  def page_views
    @page_views = @dataset.dataset_page_audits.group(:page_path).count.to_a.sort_by(&:second)
  end

  # POST /datasets/1/create_access
  def create_access
    user_email = params[:user_email].to_s.strip
    if user = User.current.find_by_email(user_email.split("[").last.to_s.split("]").first)
      @dataset_user = @dataset.dataset_users.where(user_id: user.id, role: params[:role]).first_or_create
      redirect_to collaborators_dataset_path(@dataset, dataset_user_id: @dataset_user ? @dataset_user.id : nil)
    else
      redirect_to collaborators_dataset_path(@dataset), alert: "User \"#{user_email}\" was not found."
    end
  end

  # POST /datasets/1/remove_access
  def remove_access
    if @dataset_user = @dataset.dataset_users.find_by(id: params[:dataset_user_id])
      @dataset_user.destroy
    end
    redirect_to collaborators_dataset_path(@dataset)
  end

  # Handled by Pageable
  # GET/POST/PATCH /datasets/1/pull_changes
  # def pull_changes
  # end

  # POST /datasets/1/reset_index
  def reset_index
    @dataset.reset_index_in_background!(params[:path], recompute: params[:recompute].to_s == "1")
    redirect_to files_dataset_path(@dataset, path: @dataset.find_file_folder(params[:path]))
  end

  # POST /datasets/1/set_public_file.js
  def set_public_file
    @dataset_file = @dataset.dataset_files.find_by(full_path: params[:path], is_file: true)
    @dataset_file.update(publicly_available: (params[:public].to_s == "1")) if @dataset_file
  end

  # # GET
  # def settings
  # end

  # Handled by Pageable
  # GET /datasets/1/sync
  # def sync
  # end

  # GET /datasets/new
  def new
    @dataset = Dataset.new
    render layout: "layouts/application"
  end

  # POST /datasets
  def create
    @dataset = current_user.datasets.new(dataset_params)
    if @dataset.save
      @dataset.git_init_repository!
      redirect_to @dataset, notice: "Dataset was successfully created."
    else
      render :new, layout: "layouts/application"
    end
  end

  # # GET /datasets/1/edit
  # def edit
  # end

  # PATCH /datasets/1
  def update
    if @dataset.update(dataset_params)
      @dataset.git_init_repository!
      redirect_to [:settings, @dataset], notice: "Dataset was successfully updated."
    else
      render :edit
    end
  end

  # DELETE /datasets/1
  def destroy
    @dataset.destroy
    redirect_to datasets_path, notice: "Dataset was successfully deleted."
  end

  private

  def dataset_params
    params[:dataset] ||= { blank: "1" }
    parse_date_if_key_present(:dataset, :release_date)
    params.require(:dataset).permit(
      :organization_id, :name, :description, :slug, :logo, :logo_cache, :released,
      :git_repository, :release_date, :info_what, :info_who,
      :info_when, :info_funded_by, :info_citation, :subjects,
      :age_min, :age_max, :time_frame, :polysomnography, :actigraphy, :doi,
      :featured
    )
  end

  def check_organization_editor
    return if current_user&.organization_editor?

    redirect_to datasets_path
  end

  def find_editable_dataset_or_redirect
    super(:id)
  end

  def scope_order(scope)
    @order = params[:order]
    scope.order(Arel.sql(DataRequest::ORDERS[params[:order]] || DataRequest::DEFAULT_ORDER))
  end
end
