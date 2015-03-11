class ShowcaseController < ApplicationController

  layout 'application-full'

  def index
  end

  def show
    showcases = %w( search-nsrr
                    where-to-start
                    shaun-purcell-genetics-of-sleep-spindles
                  )
    if showcases.include?(params[:slug])
      render params[:slug].to_s.gsub('-', '_')
    else
      redirect_to showcase_path
    end
  end

end
