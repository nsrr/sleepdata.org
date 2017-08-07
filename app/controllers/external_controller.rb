# frozen_string_literal: true

# Displays publicly available pages
class ExternalController < ApplicationController
  # GET /about
  def about
    @users = User.core_members.order(:last_name, :first_name)
  end

  # GET /about/academic-user-group
  def aug
    @users = User.aug_members.order(:last_name, :first_name)
  end

  # # GET /contact
  # def contact
  # end

  # # GET /about/contributors
  # def contributors
  # end

  # # GET /about/data-sharing-language
  # def datasharing
  # end

  # # GET /demo
  # def demo
  # end

  # GET /landing
  def landing
    @datasets = Dataset.release_scheduled
    @variables = Variable.latest.where(commonly_used: true).order('RANDOM()').limit(10)
    @tools = Tool.current.where(slug: ['physiomimi', 'edf-viewer', 'block-edf-loader']).order(:name)
  end

  # # GET /share
  # def share
  # end

  # # GET /sitemap
  # def sitemap
  # end

  # # GET /team
  # def team
  # end

  # # GET /version
  # # GET /version.json
  # def version
  # end

  # # POST /preview
  # def preview
  # end

  # GET /sitemap.xml.gz
  def sitemap_xml
    sitemap_xml = File.join(CarrierWave::Uploader::Base.root, 'sitemaps', 'sitemap.xml.gz')
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
