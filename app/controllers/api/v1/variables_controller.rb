class Api::V1::VariablesController < Api::V1::BaseController
  before_action :set_or_create_version, only: [:create, :create_or_update]
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
    if @variable.save
      render :show, status: :created, location: api_v1_variable_path(@variable)
    else
      render json: @variable.errors, status: :unprocessable_entity
    end
  end

  # POST /api/v1/variables/create_or_update.json
  def create_or_update
    @errors = []
    @variable = dataset_version_variables.where(name: params[:variable][:name]).first_or_create(variable_core_params)
    if params[:domain] && params[:domain][:name].present?
      @domain = dataset_version_domains.where(name: params[:domain][:name]).first_or_create
      if @domain
        @domain.update(domain_optional_params)
        params[:variable][:domain_id] = @domain.id
      end
    end

    @variable.variable_forms.destroy_all
    (params[:forms] || []).each do |form_params|
      form = dataset_version_forms.where(name: form_params[:name]).first_or_create
      if form && form.valid?
        form.update(folder: form_params[:folder], display_name: form_params[:display_name], code_book: form_params[:code_book])
        @variable.forms << form
      else
        @errors << "Invalid form name: #{form_params[:name]}"
      end
    end

    if @errors.count > 0
      render json: { errors: @errors }, status: :unprocessable_entity
    elsif @variable.update(variable_optional_params)
      render :show, status: :ok, location: api_v1_variable_path(@variable)
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

  def variable_core_params
    params.require(:variable).permit(:name, :display_name, :variable_type)
  end

  def variable_optional_params
    params.require(:variable).permit(
      :folder, :description, :units, :calculation, :commonly_used, :domain_id,
      :stats_n, :stats_mean, :stats_stddev, :stats_median, :stats_min, :stats_max, :stats_unknown, :stats_total, :spout_stats,
      { labels: [] })
  end

  def variable_params
    params.require(:variable).permit(
      :name, :display_name, :variable_type, :folder, :description,  :units,
      :calculation, :commonly_used, :domain_id,
      :stats_n, :stats_mean, :stats_stddev, :stats_median, :stats_min, :stats_max, :stats_unknown, :stats_total, :spout_stats,
      { labels: [] }).tap
    # TODO: Missing known_issues
  end

  def domain_core_params
    params.require(:domain).permit(:name)
  end

  def domain_optional_params
    params.require(:domain).permit(:folder, options: [:display_name, :value, :description, :missing])
  end

  def dataset_version_variables
    @dataset.variables.where(dataset_version_id: @dataset_version.id)
  end

  def dataset_version_domains
    @dataset.domains.where(dataset_version_id: @dataset_version.id)
  end

  def dataset_version_forms
    @dataset.forms.where(dataset_version_id: @dataset_version.id)
  end
end
