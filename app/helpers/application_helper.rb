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
    "#{SITE_URL.split('//').first}//#{SITE_URL.split('//').last.split('/').first}"
  end

  def simple_markdown(text, target_blank = true, table_class = '')
    result = ''
    markdown = Redcarpet::Markdown.new( Redcarpet::Render::HTML, no_intra_emphasis: true, fenced_code_blocks: true, autolink: true, strikethrough: true, superscript: true, tables: true )
    result = markdown.render(replace_numbers_with_ascii(text.to_s))
    result = add_table_class(result, table_class) unless table_class.blank?
    result = expand_relative_paths(result)
    result = page_headers(result)
    target_blank ? target_link_as_blank(result) : result.html_safe
  end

  private

    # :pages_path => 'http://SITEURL/datasets/slug/pages/'
    def expand_relative_paths(text)
      result = text.to_s.gsub(/<a href="(?:\:datasets\_path\:)(.*?)">/, '<a href="' + request.script_name + '/datasets\1">')
      result = result.gsub(/<img src="(?:\:datasets\_path\:)(.*?)">/, '<img src="' + request.script_name + '/datasets\1">')
      result = result.gsub(/<a href="(?:\:tools\_path\:)(.*?)">/, '<a href="' + request.script_name + '/tools\1">').html_safe
      result.gsub(/<img src="(?:\:tools\_path\:)(.*?)">/, '<img src="' + request.script_name + '/tools\1">').html_safe
    end

    def page_headers(text)
      text.to_s.gsub(/<h2>/, '<h2 class="markdown-header">').html_safe
    end

    def target_link_as_blank(text)
      text.to_s.gsub(/<a(.*?)>/, '<a\1 target="_blank">').html_safe
    end

    def add_table_class(text, table_class)
      text.to_s.gsub(/<table>/, "<table class=\"#{table_class}\">").html_safe
    end

    def replace_numbers_with_ascii(text)
      text.gsub(/^[ \t]*(\d)/){|m| ascii_number($1)}
    end

    def ascii_number(number)
      "&##{(number.to_i + 48).to_s};"
    end

end
