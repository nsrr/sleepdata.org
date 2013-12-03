class WelcomeController < ApplicationController
  before_action :authenticate_user!,        only: [ :whatsmyip ]
  before_action :check_system_admin,        only: [ :whatsmyip ]

  def whatsmyip
  end

  def collection
    dataset_scope = if current_user
      current_user.all_viewable_datasets
    else
      Dataset.current.where( public: true )
    end
    @datasets = dataset_scope

    @labels = params[:s].to_s.split(/\s/).collect{|l| l.to_s.gsub(/[^\w\d%]/, '')}
    @search = @labels.first
    @search = 'a' if @search.blank?
    search_empty = nil
    search_empty = @search if @search.length == 1 and @labels.size <= 1
    @labels = (@labels + [@search]).uniq.select{|l| l.size > 1}

    if search_empty
      @variables = Variable.where( dataset_id: @datasets.pluck(:id) ).where("name LIKE ?", "#{search_empty}%").order(:name)
    else
      @variables = Variable.where( dataset_id: @datasets.pluck(:id) ).where("search_terms ~* ?", @labels.collect{|l| "(\\m#{l})"}.join("|"))
      @variables.sort!{|a,b| [b.score(@labels), a.name] <=> [a.score(@labels), b.name]}
    end
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

  def wget
    if params[:choose] == '1'
      render 'tools/wget'
    elsif mac? or linux?
      redirect_to wget_src_path
    elsif windows?
      redirect_to wget_windows_path
    else
      render 'tools/wget'
    end
  end

  def wget_src
    render 'tools/wget/wget_src'
  end

  def wget_windows
    render 'tools/wget/wget_windows'
  end

  private

    def mac?
      !!(ua =~ /Mac OS X/)
    end

    def windows?
      !!(ua =~ /Windows/)
    end

    def linux?
      !!(ua =~ /Linux/)
    end

    def ua
      request.env['HTTP_USER_AGENT']
    end

end
