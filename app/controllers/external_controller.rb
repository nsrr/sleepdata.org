# frozen_string_literal: true

# Displays publicly available pages.
class ExternalController < ApplicationController
  # GET /about
  def about
    @users = User.core_members.order(:full_name)
    render layout: "layouts/full_page"
  end

  # GET /about/academic-user-group
  def aug
    @users = User.aug_members.order(:full_name)
    render layout: "layouts/full_page"
  end

  # # GET /contact
  # def contact
  # end

  # GET /about/contributors
  def contributors
    render layout: "layouts/full_page"
  end

  # GET /about/data-sharing-language
  def datasharing
    render layout: "layouts/full_page"
  end

  # # GET /demo
  # def demo
  # end

  # GET /landing
  def landing
    render layout: "layouts/full_page_custom_header"
  end

  # GET /share
  def share
    render layout: "layouts/full_page"
  end

  # GET /about/fair-data-principles
  def fair
    render layout: "layouts/full_page"
  end

  # # GET /sitemap
  # def sitemap
  # end

  # GET /team
  def team
    render layout: "layouts/full_page"
  end

  # GET /version
  # GET /version.json
  def version
    render layout: "layouts/full_page"
  end

  # # POST /preview
  # def preview
  # end

  # GET /sitemap.xml.gz
  def sitemap_xml
    sitemap_xml = File.join(CarrierWave::Uploader::Base.root, "sitemaps", "sitemap.xml.gz")
    if File.exist?(sitemap_xml)
      send_file sitemap_xml
    else
      head :ok
    end
  end

  # # GET /voting
  # def voting
  # end
end
