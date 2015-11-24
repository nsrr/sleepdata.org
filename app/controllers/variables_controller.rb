class VariablesController < ApplicationController
  before_action :set_viewable_dataset,      only: [:show, :index, :image]
  before_action :redirect_without_dataset,  only: [:show, :index, :image]
  before_action :set_viewable_variable,     only: [:show, :image]
  before_action :redirect_without_variable, only: [:show]

  def index
    variable_scope = @dataset.variables.search(params[:s]).with_folder(params[:folder]).order(:folder, :name)
    variable_scope = variable_scope.where( commonly_used: true ) if params[:common] == '1'
    @folders = variable_scope.pluck(:folder).uniq.collect{ |f| f.gsub(/^#{params[:folder]}(\/)?/, '').split('/').first }.uniq.compact.sort
    @variables = variable_scope.page(params[:page]).per( 100 )
  end

  def show
    graphs_folder = File.join(@dataset.root_folder, 'dd', 'graphs')
    valid_folders = if File.exist?(graphs_folder)
                      (Dir.entries(graphs_folder) - ['.','..']).select { |f| !File.file?(f) }
                    else
                      []
                    end
    @version = (valid_folders.include?(params[:v].to_s.strip) ? valid_folders.select{|f| f == params[:v].to_s.strip}.first : @variable.version.to_s)
  end

  def image
    head :ok and return unless @variable
    size = 'lg' if params[:size] == 'lg'
    image_name = [@variable.name, size].compact.join('-')

    if params[:format] == 'svg'
      image_file = File.join(@dataset.root_folder, 'dd', 'images', "#{@variable.version}", "#{image_name}.svg")
      send_file image_file, disposition: 'inline', type: 'image/svg+xml' if File.file?(image_file)
    else
      image_file = File.join(@dataset.root_folder, 'dd', 'images', "#{@variable.version}", "#{image_name}.png")
      send_file image_file if File.file?(image_file)
    end
  end

  private

  def set_viewable_variable
    @variable = @dataset.variables.find_by_name(params[:id])
  end

  def redirect_without_variable
    empty_response_or_root_path(dataset_variables_path(@dataset)) unless @variable
  end
end
