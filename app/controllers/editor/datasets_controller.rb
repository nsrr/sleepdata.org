# frozen_string_literal: true

# Allows dataset editors to manage individual datasets.
class Editor::DatasetsController < ApplicationController
  before_action :authenticate_user!
  before_action :find_editable_dataset_or_redirect

  # Concerns
  include Pageable

  # GET/POST/PATCH /datasets/1/audits
  def audits
    audit_scope = @dataset.dataset_file_audits.order(created_at: :desc)
    audit_scope = audit_scope.where(user_id: params[:user_id].blank? ? nil : params[:user_id]) if params.key?(:user_id)
    audit_scope = audit_scope.where(medium: params[:medium].blank? ? nil : params[:medium]) if params.key?(:medium)
    audit_scope = audit_scope.where(remote_ip: params[:remote_ip].blank? ? nil : params[:remote_ip]) if params.key?(:remote_ip)
    @audits = audit_scope
  end

  # GET /datasets/1/collaborators
  def collaborators
  end

  # POST /datasets/1/create_access
  def create_access
    user_email = params[:user_email].to_s.strip
    if user = User.current.find_by_email(user_email.split('[').last.to_s.split(']').first)
      @dataset_user = @dataset.dataset_users.where( user_id: user.id, role: params[:role] ).first_or_create
      redirect_to collaborators_dataset_path(@dataset, dataset_user_id: @dataset_user ? @dataset_user.id : nil)
    else
      redirect_to collaborators_dataset_path(@dataset), alert: "User '<code>#{user_email}</code>' was not found."
    end
  end

  # POST /datasets/1/remove_access
  def remove_access
    if @dataset_user = @dataset.dataset_users.find_by_id(params[:dataset_user_id])
      @dataset_user.destroy
    end
    redirect_to collaborators_dataset_path(@dataset)
  end

  # GET/POST/PATCH /datasets/1/pull_changes
  def pull_changes
  end

  # POST /datasets/1/reset_index
  def reset_index
    @dataset.reset_index_in_background!(params[:path], recompute: params[:recompute].to_s == '1')
    redirect_to files_dataset_path(@dataset, path: @dataset.find_file_folder(params[:path]))
  end

  # POST /datasets/1/set_public_file
  # TODO: Make this AJAX
  def set_public_file
    @dataset_file = @dataset.dataset_files.find_by(full_path: params[:path], is_file: true)
    if @dataset_file
      @dataset_file.update publicly_available: (params[:public].to_s == '1')
    end
    redirect_to files_dataset_path(@dataset, path: @dataset.find_file_folder(params[:path]))
  end

  # Handled by Pageable
  # GET /datasets/1/sync
  # def sync
  # end

  # GET /datasets/1/edit
  def edit
  end

  # PATCH /datasets/1
  def update
    if @dataset.update(dataset_params)
      redirect_to @dataset, notice: 'Dataset was successfully updated.'
    else
      render :edit
    end
  end

  # GET/POST/PATCH /datasets/1/destroy
  def destroy
  end

  private

  def find_editable_dataset_or_redirect
    super(:id)
  end

  def dataset_params
    params[:dataset] ||= { blank: '1' }
    params[:dataset][:release_date] = parse_date(params[:dataset][:release_date])
    params.require(:dataset).permit(
      :name, :description, :slug, :logo, :logo_cache, :public,
      :all_files_public, :git_repository, :release_date, :info_what, :info_who,
      :info_when, :info_funded_by, :info_citation, :info_size
      )
  end
end
