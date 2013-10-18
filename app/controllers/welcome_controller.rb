class WelcomeController < ApplicationController
  def index
  end

  def manifest
    render partial: 'manifest.text.erb'
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
