# Displays publicly available pages
class ExternalController < ApplicationController
  def contact
  end

  def landing
    @datasets = Dataset.release_scheduled
  end
end
