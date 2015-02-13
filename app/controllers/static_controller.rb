class StaticController < ApplicationController

  layout 'application-full'

  def demo
  end

  def showcase
  end

  def parallax
    render layout: 'layouts/application-parallax'
  end

  def parallax2
    render layout: 'layouts/application-parallax'
  end

  def version
  end

end
