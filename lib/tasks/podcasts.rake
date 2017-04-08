require 'csv'
require 'nokogiri'
require 'open-uri'
require 'byebug'

namespace :podcasts do
  CATS = [:arts, :business, :comedy, :education, :games_and_hobbies,
          :government_and_organizations, :health, :kids_and_family, :music, :news_and_politics,
          :religion_and_spirituality, :science_and_medicine, :society_and_culture,
          :sports_and_recreation, :tv_and_film, :technology,
          "arts-design", "arts-fashion-beauty", "arts-food", "arts-literature",
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


  desc "download podcasts"
  task download: :environment do
    CATS.each do |category|
      CSV.open("materials/podcasts/#{category.to_s}.csv", "w") do |podcast_list|
        csv_text = File.read("materials/categories/#{category.to_s}.csv")
        csv = CSV.parse(csv_text)
        csv.each do |row|
          url = row[1]
          doc = Nokogiri::HTML(open(url))
          puts "\n ======== #{url}"
          podcasts = doc.xpath('//*[@id="selectedcontent"]/div/ul/li/a')

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

      dir = "materials/podcasts/"
      %x( mv #{dir}#{category.to_s}.csv #{dir}temp.csv )
      %x( sort #{dir}temp.csv | uniq -u > #{dir}#{category.to_s}.csv )
      %x( rm #{dir}temp.csv )
    end
  end


  desc "import podcasts"
  task import: :environment do
    CATS.each do |category|
      puts category.to_s

      # Podcast.where(category: category.to_s)
      #        .delete_all()

      podcasts = []
      podcast_list = File.read("materials/podcasts/#{category.to_s}.csv")
      csv = CSV.parse(podcast_list)
      csv.each do |row|
        podcasts << Podcast.new(category: category.to_s, title: row[1], itunes_url: row[0])
      end

      Podcast.transaction do
        podcasts.map(&:save)
      end
    end
  end


  desc "set to done"
  task set_to_done: :environment do
    urls = Podcast.where(category: "science-medicine-natural-sciences").select(:itunes_url)
    puts urls.count.to_s + " urls exported."

    podcasts = Podcast.where(itunes_url: urls)
    podcasts.each {|p| p.done = true}

    Podcast.transaction do
      podcasts.map(&:save)
    end
    puts podcasts.count.to_s + " podcasts done with this category."

    todo = Podcast.where(done: [nil, false]).count
    puts todo.to_s + " podcasts remaining."

    done = Podcast.where(done: true).count
    puts done.to_s + " podcasts done overall."
  end
end