module ApplicationHelper
  def simple_check(checked)
    content_tag(:span, '', class: "glyphicon #{checked ? 'glyphicon-ok' : 'glyphicon-unchecked'}")
  end

  def simple_markdown_no_lists(text, target_blank: true, table_class: '', allow_links: true, allow_lists: true)
    allow_lists = false
    simple_markdown(text, target_blank, table_class, allow_links, allow_lists)
  end

  def simple_markdown(text, target_blank = true, table_class = '', allow_links = true, allow_lists = true)
    result = ''
    markdown = Redcarpet::Markdown.new( Redcarpet::Render::HTML, no_intra_emphasis: true, fenced_code_blocks: true, autolink: true, strikethrough: true, superscript: true, tables: true, lax_spacing: true, space_after_headers: true, underline: true, highlight: true, footnotes: true )
    result = text.to_s
    result = replace_numbers_with_ascii(result) unless allow_lists
    result = markdown.render(result)
    result = result.encode('UTF-16', undef: :replace, invalid: :replace, replace: '').encode('UTF-8')
    result = add_table_class(result, table_class) unless table_class.blank?
    result = expand_relative_paths(result)
    unless allow_links
      result = remove_links(result)
      result = remove_images(result)
      result = remove_tables(result)
    end
    result = target_link_as_blank(result) if target_blank
    result = link_usernames(result)
    result.html_safe
  end

  def th_sort_field(order, sort_field, display_name)
    sort_field_order = (order == sort_field) ? "#{sort_field} DESC" : sort_field
    if order == sort_field
      css_class = 'sort-up'
      selected_class = 'sort-selected'
    elsif order == sort_field + ' DESC NULLS LAST'
      css_class = 'sort-down'
      selected_class = 'sort-selected'
    end
    content_tag(:th, class: ['nowrap', selected_class]) do
      link_to url_for(params.merge(order: sort_field_order)), style: 'text-decoration:none', class: css_class do
        display_name.to_s.html_safe
      end
    end.html_safe
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

  def target_link_as_blank(text)
    text.to_s.gsub(/<a(.*?)>/m, '<a\1 target="_blank">').html_safe
  end

  def remove_links(text)
    text.to_s.gsub(/<a[^>]*? href="(.*?)">(.*?)<\/a>/m, '\1')
  end

  def remove_images(text)
    text.to_s.gsub(/<img(.*?)>/m, '')
  end

  def remove_tables(text)
    text.to_s.gsub(/<table(.*?)>(.*?)<\/table>/m, '')
  end

  def add_table_class(text, table_class)
    text.to_s.gsub(/<table>/, "<table class=\"#{table_class}\">").html_safe
  end

  def replace_numbers_with_ascii(text)
    text.gsub(/^[ \t]*(\d)/) { |m| ascii_number($1) }
  end

  def ascii_number(number)
    "&##{(number.to_i + 48).to_s};"
  end
end
