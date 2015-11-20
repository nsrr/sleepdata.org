# Provides several pages that showcase different aspects of the NSRR
class ShowcaseController < ApplicationController
  def index
  end

  def show
    if showcases.include? params[:slug]
      render params[:slug].tr('-', '_')
    else
      redirect_to showcase_path
    end
  end

  private

  def showcases
    %w(search-nsrr where-to-start shaun-purcell-genetics-of-sleep-spindles
       matt-butler-novel-sleep-measures-and-cardiovascular-risk)
  end
end
