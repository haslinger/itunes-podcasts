require 'csv'
require 'nokogiri'
require 'open-uri'
require 'byebug'

# Collect iTunes URLs for each of their podcasts

CATEGORIES =  [:arts, :business, :comedy, :education, :games_and_hobbies,
               :government_and_organizations, :health, :kids_and_family, :music, :news_and_politics,
               :religion_and_spirituality, :science_and_medicine, :society_and_culture,
               :sports_and_recreation, :tv_and_film, :technology]

CATEGORIES.each do |category|
  CSV.open("podcasts/itunes-podcast-lists-#{category.to_s}.csv", "w") do |podcast_list|
    csv_text = File.read("categories/itunes-podcast-category-lists-#{category.to_s}.csv")
    csv = CSV.parse(csv_text)
    csv.each do |row|
      url = row[1]
      doc = Nokogiri::XML(open(url))
      podcasts = doc.xpath('//results[0]/feedUrl')

      podcasts.each do |podcast|
        podcast_url = podcast["href"]
        podcast_name = podcast.text

        if podcast_url.start_with?("http") &&  podcast_name != "Apple Store App"
          puts "#{podcast_url} :: #{podcast_name}"
          podcast_list << [podcast_url, podcast_name]
        end
      end
    end
  end
end