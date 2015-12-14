class CommunityTool < ActiveRecord::Base
  # Constants
  STATUS = %w(submitted accepted rejected)

  # Concerns
  include Deletable

  # Named Scopes

  # Model Validation
  validates :user_id, :url, :description, :status, presence: true

  # Model Relationships
  belongs_to :user

  # Community Tool Methods

  def name
    "Tool ##{id}"
  end

  def safe_url?
    %w(http https ftp).include?(URI.parse(url).scheme)
  rescue
    false
  end

  def readme_content
    if readme_url.present?
      uri = URI.parse(readme_url)
      http = Net::HTTP.new(uri.host, uri.port)
      if uri.scheme == 'https'
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      end

      req = Net::HTTP::Get.new(uri.path)
      response = http.start do |http|
                   http.request(req)
                 end
      response.body
    end
  rescue
    nil
  end

  def readme_url
    if github_readme?
      url.gsub(%r{^https://github.com/}, 'https://raw.githubusercontent.com/') + '/master/README.md'
    elsif github_gist?
      url.gsub(%r{^https://gist.github.com/}, 'https://gist.githubusercontent.com/') + '/raw'
    end
  end

  def github_gist?
    %r{^https://gist.github.com/} =~ url
  end

  def github_readme?
    %r{^https://github.com/} =~ url
  end

  def markdown?
    if github_gist?
      uri = URI.parse(url + '.json')
      http = Net::HTTP.new(uri.host, uri.port)
      if uri.scheme == 'https'
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      end

      req = Net::HTTP::Get.new(uri.path)
      response = http.start do |http|
                   http.request(req)
                 end
      filename = JSON.parse(response.body)['files'].first
      /\.md$/ =~ filename || /\.markdown$/ =~ filename
    else
      github_readme?
    end
  rescue
    false
  end
end