require 'open-uri'
require 'json'

namespace :feeds do
  desc "import feeds"
  task import: :environment do
    📁 = "/usr/share/sounds/freedesktop/stereo/"

    while Podcast.where(feed_url: nil,
                        failed: [nil, false])
                 .count > 0
      podcasts = Podcast.where(feed_url: nil,
                               failed: [nil, false])
                        .limit(100)
      updated_podcasts = []

      podcasts.each do |podcast|
        puts podcast.category + " <=> " + podcast.title
        id = podcast.itunes_url.split("/").last[2..20]

        begin
          metadata = open("https://itunes.apple.com/lookup?id=#{id}&entity=podcast",
                          read_timeout: 5){|f| f.read }
          podcast.feed_url = JSON.parse(metadata)["results"].first["feedUrl"]
          # %x( paplay #{📁}audio-volume-change.oga )
        rescue
          podcast.failed = true
          # %x( paplay #{📁}bell.oga )
        end

        updated_podcasts << podcast
      end

      Podcast.transaction { updated_podcasts.map(&:save) }
      %x( paplay #{📁}message-new-instant.oga )
    end
  end
end