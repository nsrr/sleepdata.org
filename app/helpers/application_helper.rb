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
    target_blank ? target_link_as_blank(result) : result.html_safe
  end

  private

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
