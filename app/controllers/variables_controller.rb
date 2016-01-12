class VariablesController < ApplicationController
  before_action :set_viewable_dataset
  before_action :redirect_without_dataset
  before_action :set_dataset_version
  before_action :set_viewable_variable,     only: [:show, :graphs, :form, :known_issues, :related, :history]
  before_action :redirect_without_variable, only: [:show, :graphs, :form, :known_issues, :related, :history]

  def index
    variable_scope = @dataset.variables.with_folder(params[:folder])
    variable_scope = variable_scope.where(dataset_version_id: @dataset_version.id) if @dataset_version
    if params[:s].blank?
      @variables = variable_scope.page(params[:page]).per(100).order('commonly_used desc', :folder, :name)
      @folders = variable_scope.pluck(:folder).uniq.collect { |f| f.gsub(/^#{params[:folder]}(\/)?/, '').split('/').first }.uniq.compact.sort
      @total_count = @variables.total_count
    else
      @variables = variable_scope.search(params[:s])
      @folders = variable_scope.pluck(:folder).uniq.collect { |f| f.gsub(/^#{params[:folder]}(\/)?/, '').split('/').first }.uniq.compact.sort
      @total_count = @variables.count
    end
  end

  def show
  end

  def graphs
  end

  def form
    @form = @variable.forms.find_by_name params[:name]
    redirect_to [@dataset, @variable] unless @form
  end

  def related
  end

  def known_issues
  end

  def history
  end

  private

  def set_dataset_version
    @dataset_version = @dataset.dataset_versions.find_by_version params[:v]
    @dataset_version = @dataset.dataset_version unless @dataset_version
  end

  def set_viewable_variable
    variable_scope = @dataset.variables
    variable_scope = variable_scope.where(dataset_version_id: @dataset_version.id) if @dataset_version
    @variable = variable_scope.find_by_name(params[:id])
  end

  def redirect_without_variable
    empty_response_or_root_path(dataset_variables_path(@dataset)) unless @variable
  end
end
