class WelcomeController < ApplicationController
  before_action :authenticate_user!,        only: [ :whatsmyip ]
  before_action :check_system_admin,        only: [ :whatsmyip ]

  def whatsmyip
  end
  
  def aug
    @users = User.current.where( aug_member: true).order(:last_name).page(params[:page]).per( 40 )
  end

  def collection
    dataset_scope = if current_user
      current_user.all_viewable_datasets
    else
      Dataset.current.where( public: true )
    end

    dataset_scope = dataset_scope.where( slug: params[:d].split(/\s/) ) unless params[:d].blank?

    @datasets = dataset_scope

    @dataset = @datasets.first if @datasets.count == 1

    @labels = params[:s].to_s.split(/\s/).collect{|l| l.to_s.gsub(/[^\w\d%]/, '')}
    @search = @labels.first
    @search = 'a' if @search.blank?
    search_empty = nil
    search_empty = @search if @search.length == 1 and @labels.size <= 1
    @labels = (@labels + [@search]).uniq.select{|l| l.size > 1}

    variable_scope = Variable.where( dataset_id: @datasets.pluck(:id) )

    if search_empty
      @variables = variable_scope.where("name LIKE ?", "#{search_empty}%").order(:name)
    else
      @variables = variable_scope.where("search_terms ~* ?", @labels.collect{|l| "(\\m#{l})"}.join("|"))
      @variables.sort!{|a,b| [b.score(@labels), a.name] <=> [a.score(@labels), b.name]}
    end

    @list = List.find_by_id( cookies.signed[:list_id] )
  end

  def collection_modal
    dataset_scope = if current_user
      current_user.all_viewable_datasets
    else
      Dataset.current.where( public: true )
    end

    @dataset = dataset_scope.find_by_slug(params[:slug])
    @variable = @dataset.variables.find_by_name(params[:basename]) if @dataset
  end

  def index
  end

  def wget_src
    render 'tools/wget/wget_src'
  end

  def wget_windows
    render 'tools/wget/wget_windows'
  end

end
