require 'csv'
require 'open-uri'
require 'json'

# Collect feed URLs for Itunes URLs

CATEGORIES =  [:kids_and_family]

# :arts, :business, :comedy, :education, :games_and_hobbies, :health,
# :music, :news_and_politics, :religion_and_spirituality, :society_and_culture,
# :sports_and_recreation, :tv_and_film, :technology

CATEGORIES.each do |category|
  CSV.open("feeds/#{category.to_s}.csv", "a") do |feed_list|
    csv_text = File.read("podcasts/#{category.to_s}.csv")
    csv = CSV.parse(csv_text)

    csv.each do |row|
      podcast_title = row[1]
      id = row[0].split("/").last[2..20]

      sleep 0.1 # throttling :-)

      begin
        metadata = open("https://itunes.apple.com/lookup?id=#{id}&entity=podcast"){|f| f.read }
        feed_url = JSON.parse(metadata)["results"].first["feedUrl"]

        puts "#{feed_url}, #{podcast_title}"
        feed_list << [feed_url, podcast_title]

        `paplay /usr/share/sounds/freedesktop/stereo/audio-volume-change.oga` # makes some noise
      rescue
        `paplay /usr/share/sounds/freedesktop/stereo/suspend-error.oga`
        raise :network_error
      end
    end
  end
end