class WelcomeController < ApplicationController
  before_action :authenticate_user!,        only: [ :whatsmyip ]
  before_action :check_system_admin,        only: [ :whatsmyip ]

  def whatsmyip
  end
  
  def aug
    unless params[:s].blank?
      @tokens = params[:s].to_s.gsub(',', ' ').split(/\s+/).collect{|l| l.to_s.gsub(/[^\w\d%]/, '')}
      if @tokens.size == 1
        s = params[:s] = @tokens.first
        user_scope = User.current.where("first_name ~* ? or last_name ~* ?", "(\\m#{s})", "(\\m#{s})")
      elsif @tokens.size == 2
        s1 = @tokens[0]
        s2 = @tokens[1]
        user_scope = User.where("(first_name ~* ? and last_name ~* ?) or (last_name ~* ? and first_name ~* ?)", "(\\m#{s1})", "(\\m#{s2})", "(\\m#{s1})", "(\\m#{s2})")
      else 
        user_scope = User.where('false')
      end 
    else
      user_scope = User.current
    end
    @users = user_scope.order(:last_name).page(params[:page]).per( 20 )
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
