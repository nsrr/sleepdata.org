module ApplicationHelper

  def mac?
    !!(ua =~ /Mac OS X/)
  end

  def windows?
    !!(ua =~ /Windows/)
  end

  def linux?
    !!(ua =~ /Linux/)
  end

  def ua
    request.env['HTTP_USER_AGENT']
  end

  def site_prefix
    "#{SITE_URL.split('//').first}//#{SITE_URL.split('//').last.split('/').first}"
  end

  def simple_markdown(text)
    markdown = Redcarpet::Markdown.new( Redcarpet::Render::HTML, no_intra_emphasis: true, fenced_code_blocks: true, autolink: true, strikethrough: true, superscript: true )
    target_link_as_blank(markdown.render(replace_numbers_with_ascii(text.to_s)))
  end

  private

    def target_link_as_blank(text)
      text.to_s.gsub(/<a(.*?)>/, '<a\1 target="_blank">').html_safe
    end

    def replace_numbers_with_ascii(text)
      text.gsub(/^[ \t]*(\d)/){|m| ascii_number($1)}
    end

    def ascii_number(number)
      "&##{(number.to_i + 48).to_s};"
    end


end
