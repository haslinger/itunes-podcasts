require 'csv'
require 'nokogiri'
require 'open-uri'

namespace :podcasts do
  desc "import podcasts"
  task download: :environment do

    # Collect iTunes URLs for each of their podcasts

#    CATEGORIES = [:arts, :business, :comedy, :education, :games_and_hobbies,
#                  :government_and_organizations, :health, :kids_and_family, :music, :news_and_politics,
#                  :religion_and_spirituality, :science_and_medicine, :society_and_culture,
#                  :sports_and_recreation, :tv_and_film, :technology,

    CATEGORIES = ["arts-design", "arts-fashion-beauty", "arts-food", "arts-literature",
                  "arts-performing-arts", "arts-visual-arts", "business-business-news",
                  "business-careers", "business-investing", "business-management-marketing",
                  "business-shopping", "education-educational-technology",
                  "education-higher-education", "education-k-12", "education-language-courses",
                  "education-training", "games-hobbies-automotive", "games-hobbies-aviation",
                  "games-hobbies-hobbies", "games-hobbies-other-games", "games-hobbies-video-games",
                  "local", "national", "non-profit", "regional", "health-alternative-health",
                  "health-fitness-nutrition", "health-self-help", "health-sexuality",
                  "religion-spirituality-buddhism", "religion-spirituality-christianity",
                  "religion-spirituality-hinduism", "religion-spirituality-islam",
                  "religion-spirituality-judaism", "religion-spirituality-other",
                  "religion-spirituality-spirituality", "science-medicine-medicine",
                  "science-medicine-natural-sciences", "science-medicine-social-sciences",
                  "society-culture-history", "society-culture-personal-journals",
                  "society-culture-philosophy", "society-culture-places-travel",
                  "sports-recreation-amateur", "sports-recreation-college-high-school",
                  "sports-recreation-outdoor", "sports-recreation-professional",
                  "technology-gadgets", "technology-podcasting", "technology-software-how-to",
                  "technology-tech-news"]

    CATEGORIES.each do |category|
      CSV.open("materials/podcasts/itunes-podcast-lists-#{category.to_s}.csv", "w") do |podcast_list|
        csv_text = File.read("materials/categories/itunes-podcast-category-lists-#{category.to_s}.csv")
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

      %x( sort "podcasts/itunes-podcast-lists-#{category.to_s}.csv" | uniq -u > "podcasts/#{category.to_s}.csv" )
      %x( rm "podcasts/itunes-podcast-lists-#{category.to_s}.csv" )
    end
  end
end