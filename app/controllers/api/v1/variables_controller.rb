class Api::V1::VariablesController < Api::V1::BaseController
  before_action :set_or_create_version, only: [:create]
  before_action :set_version, only: [:show, :index, :update, :destroy]
  before_action :set_variable, only: [:show, :update, :destroy]

  # GET /api/v1/variables.json
  def index
    @variables = dataset_version_variables.order(id: :desc).limit(5)
  end

  # GET /api/v1/variables/1.json
  def show
  end

  # POST /api/v1/variables.json
  def create
    @variable = dataset_version_variables.new(variable_params)
    Rails.logger.debug "params: #{variable_params.inspect}"
    if @variable.save
      render :show, status: :created, location: api_v1_variable_path(@variable)
    else
      render json: @variable.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /api/v1/variables/1.json
  def update
    if @variable.update(variable_params)
      render :show, status: :ok, location: api_v1_variable_path(@variable)
    else
      render json: @variable.errors, status: :unprocessable_entity
    end
  end

  # DELETE /api/v1/variables/1.json
  def destroy
    @variable.destroy
    head :no_content
  end

  private

  def set_variable
    @variable = dataset_version_variables.find_by_name(params[:id])
    unless @variable
      render json: { error: "Variable '#{params[:id]}' not found. Make sure you have provided the correct dataset, version, and variable name." }, status: :unprocessable_entity
      return
    end
  end

  def variable_params
    params.require(:variable).permit(:folder, :name, :display_name, :description, :variable_type, :units, :calculation, :commonly_used, labels: [])
    # TODO: Missing domain, forms, graphs
    # TODO: Missing known_issues
    # TODO: Missing stats_n, stats_mean, stats_stddev, stats_median, stats_min, stats_max, stats_unknown, stats_total
  end

  def dataset_version_variables
    @dataset.variables.where(dataset_version_id: @dataset_version.id)
  end
end
