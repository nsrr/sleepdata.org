atom_feed(root_url: "#{ENV['website_url']}/blog") do |feed|
  feed.title('National Sleep Research Resource Blog')
  feed.updated @broadcasts.maximum(:publish_date)

  @broadcasts.each do |broadcast|
    feed.entry(broadcast,
               url: "#{ENV['website_url']}/blog/#{broadcast.to_param}",
               published: broadcast.publish_date) do |entry|
      entry.title(broadcast.title)
      entry.content(simple_markdown_new(broadcast.description, target_blank: false), type: 'html')
      entry.summary broadcast.short_description
      entry.author do |author|
        author.name(broadcast.user.forum_name)
      end
    end
  end
end
