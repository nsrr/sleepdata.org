# frozen_string_literal: true

# To run task
# rails sitemap:refresh:no_ping
# Or production
# rails sitemap:refresh RAILS_ENV=production
# https://www.google.com/webmasters/tools/

require "rubygems"
require "sitemap_generator"

SitemapGenerator.verbose = false
SitemapGenerator::Sitemap.default_host = "https://sleepdata.org"
SitemapGenerator::Sitemap.sitemaps_host = ENV["website_url"]
SitemapGenerator::Sitemap.public_path = "carrierwave/sitemaps/"
SitemapGenerator::Sitemap.sitemaps_path = ""
SitemapGenerator::Sitemap.create do
  add "/", changefreq: "weekly", priority: 0.7
  add "/blog", changefreq: "daily", priority: 0.9
  add "/forum", changefreq: "daily", priority: 0.8
  add "/about", changefreq: "weekly", priority: 0.7
  add "/contact", changefreq: "monthly", priority: 0.3
  add "/team", changefreq: "monthly", priority: 0.3
  add "/share", changefreq: "monthly", priority: 0.3
  add "/about/academic-user-group", changefreq: "monthly", priority: 0.3
  add "/about/contributors", changefreq: "monthly", priority: 0.3

  Broadcast.published.find_each do |broadcast|
    add "/blog/#{broadcast.to_param}", lastmod: broadcast.updated_at
  end

  Topic.current.find_each do |topic|
    add "/forum/#{topic.to_param}", lastmod: topic.updated_at
    if topic.last_page > 1
      (2..topic.last_page).each do |page|
        add "/forum/#{topic.to_param}/#{page}", lastmod: topic.updated_at
      end
    end
  end

  Dataset.released.each do |dataset|
    add "/datasets/#{dataset.to_param}", changefreq: "weekly"
    add "/datasets/#{dataset.to_param}/files", changefreq: "weekly"
    add "/datasets/#{dataset.to_param}/variables", changefreq: "weekly"
    dataset.variables.where(dataset_version: dataset.dataset_version).find_each do |variable|
      add "/datasets/#{dataset.to_param}/variables/#{variable.to_param}", changefreq: "monthly"
    end
  end
end
