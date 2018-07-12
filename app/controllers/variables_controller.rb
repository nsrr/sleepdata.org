# frozen_string_literal: true

# Displays data dictionary information for variables, including associated
# graphs, forms, known issues, and history.
class VariablesController < ApplicationController
  before_action :find_viewable_dataset_or_redirect
  before_action :set_dataset_version
  before_action :find_viewable_variable_or_redirect, only: [:show, :graphs, :form, :known_issues, :related, :history]

  layout "layouts/full_page_sidebar"

  # GET /datasets/:dataset_id/variables
  def index
    variable_scope = @dataset.variables.with_folder(params[:folder])
    variable_scope = variable_scope.where(dataset_version_id: @dataset_version.id) if @dataset_version
    variable_scope = \
      if params[:search].blank?
        variable_scope.order("commonly_used desc", :folder, :name)
      else
        variable_scope.search_full_text(params[:search])
      end
    @variables = variable_scope.page(params[:page]).per(100)
    @folders = variable_scope
               .pluck(:folder).uniq
               .collect { |f| f.gsub(%r{^#{params[:folder].to_s.gsub("(", "\\(").gsub(")", "\\)")}(/)?}i, "").split("/").first }
               .uniq.compact.sort
    render layout: "layouts/application"
  end

  # # GET /datasets/:dataset_id/variables/:id
  # def show
  # end

  # # GET /datasets/:dataset_id/variables/:id/graphs
  # def graphs
  # end

  def form
    @form = @variable.forms.find_by(name: params[:name])
    redirect_to [@dataset, @variable] unless @form
  end

  # # GET /datasets/:dataset_id/variables/:id/related
  # def related
  # end

  # # GET /datasets/:dataset_id/variables/:id/known_issues
  # def known_issues
  # end

  # # GET /datasets/:dataset_id/variables/:id/history
  # def history
  # end

  private

  def set_dataset_version
    @dataset_version = @dataset.dataset_versions.find_by(version: params[:v])
    @dataset_version = @dataset.dataset_version unless @dataset_version
  end

  def find_viewable_variable_or_redirect
    variable_scope = @dataset.variables
    variable_scope = variable_scope.where(dataset_version_id: @dataset_version.id) if @dataset_version
    @variable = variable_scope.find_by(name: params[:id])
    redirect_without_variable
  end

  def redirect_without_variable
    empty_response_or_root_path(dataset_variables_path(@dataset)) unless @variable
  end
end
