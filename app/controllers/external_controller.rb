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
    render layout: "layouts/full_page_custom_header"
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

  # GET /members/:username/profile_picture
  def profile_picture
    find_member
    send_file_if_present @member&.profile_picture&.thumb
  end

  private

  def find_member
    @member = User.current.find_by("LOWER(users.username) = ? or users.id = ?", params[:username].to_s.downcase, params[:username].to_i)
  end
end
