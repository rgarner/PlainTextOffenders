atom_feed :language => 'en-US' do |feed|
  feed.title "Plain Text Offenders"
  feed.description "Have you just emailed me back my own password?!"
  feed.updated @offending_sites.first.published_at

  @offending_sites.each do |item|
    feed.entry( item ) do |entry|
      entry.url offending_site_url(item)
      entry.title item.url
      entry.content "<p>#{image_tag "#{root_url}#{item.screenshot.url.gsub(/^\//, '')}"}</p><p>#{item.description}</p>", :type => 'html'

      # the strftime is needed to work with Google Reader.
      entry.updated(item.published_at.strftime("%Y-%m-%dT%H:%M:%SZ"))

      entry.author do |author|
        author.name item.name
      end
    end
  end
end