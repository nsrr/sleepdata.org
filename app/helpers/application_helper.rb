module ApplicationHelper

  # def mac?
  #   !!(ua =~ /Mac OS X/)
  # end

  # def linux?
  #   !!(ua =~ /Linux/)
  # end

  def windows?
    !!(ua =~ /Windows/)
  end

  def ua
    request.env['HTTP_USER_AGENT']
  end

  def site_prefix
    "#{ENV['website_url'].split('//').first}//#{ENV['website_url'].split('//').last.split('/').first}"
  end

  def simple_check(checked)
    checked ? '<span class="glyphicon glyphicon-ok"></span>'.html_safe : '<span class="glyphicon glyphicon-unchecked"></span>'.html_safe
  end

  def simple_markdown(text, target_blank = true, table_class = '', allow_links = true)
    result = ''
    markdown = Redcarpet::Markdown.new( Redcarpet::Render::HTML, no_intra_emphasis: true, fenced_code_blocks: true, autolink: true, strikethrough: true, superscript: true, tables: true )
    result = markdown.render(text.to_s)
    result = add_table_class(result, table_class) unless table_class.blank?
    result = expand_relative_paths(result)
    result = page_headers(result)
    result = remove_links(result) unless allow_links
    result = target_link_as_blank(result) if target_blank
    result = link_usernames(result)
    result.html_safe
  end

  private

    # :pages_path => 'http://ENV['website_url']/datasets/slug/pages/'
    def expand_relative_paths(text)
      full_path = (request ? request.script_name : ENV['website_url'])

      result = text.to_s.gsub(/<a href="(?:\:datasets\_path\:)(.*?)">/, '<a href="' + full_path + '/datasets\1">')
      result = result.gsub(/<img src="(?:\:datasets\_path\:)(.*?)">/, '<img src="' + full_path + '/datasets\1">')

      @object = @dataset || @tool

      if @object
        result = result.gsub(/<a href="(?:\:pages\_path\:)(.*?)">/, "<a href=\"#{full_path}/#{@object.class.name.pluralize.downcase}/#{@object.slug}/pages" + '\1">')
        result = result.gsub(/<img src="(?:\:pages\_path\:)(.*?)">/, "<img src=\"#{full_path}/#{@object.class.name.pluralize.downcase}/#{@object.slug}/pages" + '\1">')
        result = result.gsub(/<a href="(?:\:files\_path\:)(.*?)">/, "<a href=\"#{full_path}/#{@object.class.name.pluralize.downcase}/#{@object.slug}/files" + '\1">')
        result = result.gsub(/<img src="(?:\:files\_path\:)(.*?)">/, "<img src=\"#{full_path}/#{@object.class.name.pluralize.downcase}/#{@object.slug}/files" + '\1">')
        result = result.gsub(/<a href="(?:\:images\_path\:)(.*?)">/, "<a href=\"#{full_path}/#{@object.class.name.pluralize.downcase}/#{@object.slug}/images" + '\1">')
        result = result.gsub(/<img src="(?:\:images\_path\:)(.*?)">/, "<img src=\"#{full_path}/#{@object.class.name.pluralize.downcase}/#{@object.slug}/images" + '\1">')
      end

      result = result.gsub(/<a href="(?:\:tools\_path\:)(.*?)">/, '<a href="' + full_path + '/tools\1">')
      result = result.gsub(/<img src="(?:\:tools\_path\:)(.*?)">/, '<img src="' + full_path + '/tools\1">').html_safe
    end

    def link_usernames(text)
      full_path = (request ? request.script_name : ENV['website_url'])
      usernames = User.current.pluck(:username).reject(&:blank?).uniq.sort
      result = text.to_s
      usernames.each do |username|
        result = result.gsub(/@#{username}\b/i, "<a href=\"#{full_path}/forum?a=#{username}\">@#{username}</a>")
      end
      result.html_safe
    end

    def page_headers(text)
      text.to_s.gsub(/<h2>/, '<h2 class="markdown-header">').html_safe
    end

    def target_link_as_blank(text)
      text.to_s.gsub(/<a(.*?)>/, '<a\1 target="_blank">').html_safe
    end

    def remove_links(text)
      text.to_s.gsub(/<a href="(.*?)">(.*?)<\/a>/, '\1')
    end

    def add_table_class(text, table_class)
      text.to_s.gsub(/<table>/, "<table class=\"#{table_class}\">").html_safe
    end

end
