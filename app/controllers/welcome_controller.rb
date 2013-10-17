class WelcomeController < ApplicationController
  def index
  end

  def manifest
    render partial: 'manifest.text.erb'
  end
end
