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
  end

  def collection_modal
    dataset_scope = if current_user
      current_user.all_viewable_datasets
    else
      Dataset.current.where( public: true )
    end
    @dataset = dataset_scope.find_by_slug(params[:slug])
    @basename = params[:basename].to_s.gsub(/[^\w\d]/, '')
    @variable_file = Dir.glob("#{@dataset.root_folder}/dd/variables/**/#{@basename}.json", File::FNM_CASEFOLD).first
    @json = JSON.parse(File.read(@variable_file)) rescue @json = nil
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
