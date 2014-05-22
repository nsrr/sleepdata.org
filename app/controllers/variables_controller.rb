class VariablesController < ApplicationController

  # before_action :authenticate_user!,        only: [ :new, :edit, :create, :update, :destroy ]
  # before_action :check_system_admin,        only: [ :new, :create, :destroy ]

  before_action :set_viewable_dataset,      only: [ :show, :index ]
  # before_action :set_editable_dataset,      only: [ :edit, :update, :destroy ]
  before_action :redirect_without_dataset,  only: [ :show, :index ]  # [ :show, :edit, :update, :destroy ]

  before_action :set_viewable_variable,     only: [ :show ]
  before_action :redirect_without_variable, only: [ :show ]


  def index
    variable_scope = @dataset.variables.search(params[:s]).with_folder(params[:folder])

    @folders = variable_scope.pluck(:folder).uniq.collect{ |f| f.gsub(/^#{params[:folder]}(\/)?/, '').split('/').first }.uniq.compact.sort
    @variables = variable_scope.page(params[:page]).per( 50 )
    render layout: 'nonavigation'
  end

  def show
    render layout: 'nonavigation'
  end

  private

  def set_viewable_variable
    @variable = @dataset.variables.find_by_name(params[:id])
  end

  def redirect_without_variable
    empty_response_or_root_path( dataset_variables_path(@dataset) ) unless @variable
  end

end
