require 'open-uri'
require 'json'

namespace :feeds do
  📁 = "/usr/share/sounds/freedesktop/stereo/"

  desc "import feeds"
  task import: :environment do
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

        if well_known = Podcast.where(itunes_url: podcast.itunes_url).where.not(feed_url: nil).first
          podcast.feed_url = well_known.feed_url
          %x( paplay #{📁}audio-volume-change.oga )
        else
          begin
            metadata = open("https://itunes.apple.com/lookup?id=#{id}&entity=podcast",
                            read_timeout: 5){|f| f.read }
            podcast.feed_url = JSON.parse(metadata)["results"].first["feedUrl"]
          rescue
            podcast.failed = true
          end
        end
        updated_podcasts << podcast
      end

      Podcast.transaction { updated_podcasts.map(&:save) }
      %x( paplay #{📁}message-new-instant.oga )
    end
  end

  desc "cleanup failed"
  task cleanup: :environment do
    while Podcast.where(failed: true)
                 .count > 0
      podcasts = Podcast.where(failed: true)
                        .limit(100)
      updated_podcasts = []

      podcasts.each do |podcast|
        puts podcast.category + " <=> " + podcast.title
        id = podcast.itunes_url.split("/").last[2..20]

        if well_known = Podcast.where(itunes_url: podcast.itunes_url).where.not(feed_url: nil).first
          podcast.feed_url = well_known.feed_url
          podcast.failed = false
          updated_podcasts << podcast
          %x( paplay #{📁}audio-volume-change.oga )
        else
          begin
            metadata = open("https://itunes.apple.com/lookup?id=#{id}&entity=podcast",
                            read_timeout: 5){|f| f.read }
            podcast.feed_url = JSON.parse(metadata)["results"].first["feedUrl"]
            podcast.failed = false
            updated_podcasts << podcast
            %x( paplay #{📁}complete.oga )
          rescue
            podcast.delete()
          end
        end
      end

      Podcast.transaction { updated_podcasts.map(&:save) }
      %x( paplay #{📁}message-new-instant.oga )
    end
  end
end