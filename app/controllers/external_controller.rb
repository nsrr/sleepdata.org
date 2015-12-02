# Displays publicly available pages
class ExternalController < ApplicationController
  def about
  end

  def contact
  end

  def landing
    @datasets = Dataset.release_scheduled
  end

  def sitemap
  end
end
