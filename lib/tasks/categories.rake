require 'csv'
require 'nokogiri'
require 'open-uri'

# Bulk download scraper for iTunes podcast categories

namespace :categories do
  📁 = "https://itunes.apple.com/us/genre/podcasts-"
  ALPHABET = ('A'..'Z').to_a + ["*"]

  CATEGORIES =  {
    arts:                         "#{📁}arts/id1301?mt=2",
    business:                     "#{📁}business/id1321?mt=2",
    comedy:                       "#{📁}comedy/id1303?mt=2",
#    education:                    "#{📁}education/id1304?mt=2",
    games_and_hobbies:            "#{📁}games-hobbies/id1323?mt=2",
    government_and_organizations: "#{📁}government-organizations/id1325?mt=2",
    health:                       "#{📁}health/id1307?mt=2",
    kids_and_family:              "#{📁}kids-family/id1305?mt=2",
    music:                        "#{📁}music/id1310?mt=2",
    news_and_politics:            "#{📁}news-politics/id1311?mt=2",
#    religion_and_spirituality:    "#{📁}religion-spirituality/id1314?mt=2",
#    science_and_medicine:         "#{📁}science-medicine/id1315?mt=2",
    society_and_culture:          "#{📁}society-culture/id1324?mt=2",
#    sports_and_recreation:        "#{📁}sports-recreation/id1316?mt=2",
    tv_and_film:                  "#{📁}tv-film/id1309?mt=2",
#    technology:                   "#{📁}technology/id1318?mt=2",

    "arts-design":          "#{📁}arts-design/id1402?mt=2",
    "arts-fashion-beauty":  "#{📁}arts-fashion-beauty/id1402?mt=2",
    "arts-food":            "#{📁}arts-food/id1306?mt=2",
    "arts-literature":      "#{📁}arts-literature/id1401?mt=2",
    "arts-performing-arts": "#{📁}arts-performing-arts/id1405?mt=2",
    "arts-visual-arts":     "#{📁}arts-visual-arts/id1406?mt=2",

    "business-business-news":        "#{📁}business-business-news/id1471?mt=2",
    "business-careers":              "#{📁}business-careers/id1410?mt=2",
    "business-investing":            "#{📁}business-investing/id1412?mt=2",
    "business-management-marketing": "#{📁}business-management-marketing/id1413?mt=2",
    "business-shopping":             "#{📁}business-shopping/id1472?mt=2",

    "education-educational-technology": "#{📁}education-educational-technology/id1468?mt=2",
    "education-higher-education":       "#{📁}education-higher-education/id1416?mt=2",
    "education-k-12":                   "#{📁}education-k-12/id1415?mt=2",
#    "education-language-courses":       "#{📁}education-language-courses/id1469?mt=2",
    "education-training":               "#{📁}education-training/id1470?mt=2",

    "games-hobbies-automotive":  "#{📁}games-hobbies-automotive/id1454?mt=2",
    "games-hobbies-aviation":    "#{📁}games-hobbies-aviation/id1455?mt=2",
    "games-hobbies-hobbies":      "#{📁}games-hobbies-hobbies/id1460?mt=2",
    "games-hobbies-other-games": "#{📁}games-hobbies-other-games/id1461?mt=2",
    "games-hobbies-video-games": "#{📁}games-hobbies-video-games/id1404?mt=2",

    "local":      "#{📁}local/id1475?mt=2",
    "national":   "#{📁}national/id1473?mt=2",
    "non-profit": "#{📁}non-profit/id1476?mt=2",
    "regional":   "#{📁}regional/id1474?mt=2",

#    "health-alternative-health": "#{📁}health-alternative-health/id1481?mt=2",
    "health-fitness-nutrition":  "#{📁}health-fitness-nutrition/id1417?mt=2",
    "health-self-help":          "#{📁}health-self-help/id1420?mt=2",
    "health-sexuality":          "#{📁}health-sexuality/id1421?mt=2",

#    "religion-spirituality-buddhism":     "#{📁}religion-spirituality-buddhism/id1438?mt=2",
#    "religion-spirituality-christianity": "#{📁}religion-spirituality-christianity/id1439?mt=2",
#    "religion-spirituality-hinduism":     "#{📁}religion-spirituality-hinduism/id1463?mt=2",
#    "religion-spirituality-islam":        "#{📁}religion-spirituality-islam/id1440?mt=2",
#    "religion-spirituality-judaism":      "#{📁}religion-spirituality-judaism/id1441?mt=2",
#    "religion-spirituality-other":        "#{📁}religion-spirituality-other/id1464?mt=2",
#    "religion-spirituality-spirituality": "#{📁}religion-spirituality-spirituality/id1444?mt=2",

#    "science-medicine-medicine":         "#{📁}science-medicine-medicine/id1478?mt=2",
#    "science-medicine-natural-sciences": "#{📁}science-medicine-natural-sciences/id1477?mt=2",
#    "science-medicine-social-sciences":  "#{📁}science-medicine-social-sciences/id1479?mt=2",

#    "society-culture-history":           "#{📁}society-culture-history/id1462?mt=2",
    "society-culture-personal-journals": "#{📁}society-culture-personal-journals/id1302?mt=2",
    "society-culture-philosophy":        "#{📁}society-culture-philosophy/id1443?mt=2",
    "society-culture-places-travel":     "#{📁}society-culture-places-travel/id1320?mt=2",

#    "sports-recreation-amateur":             "#{📁}sports-recreation-amateur/id1467?mt=2",
#    "sports-recreation-college-high-school": "#{📁}sports-recreation-college-high-school/id1466?mt=2",
#    "sports-recreation-outdoor":             "#{📁}sports-recreation-outdoor/id1456?mt=2",
#    "sports-recreation-professional":        "#{📁}sports-recreation-professional/id1465?mt=2",

#    "technology-gadgets":         "#{📁}technology-gadgets/id1446?mt=2",
#    "technology-podcasting":      "#{📁}technology-podcasting/id1450?mt=2",
#    "technology-software-how-to": "#{📁}technology-software-how-to/id1480?mt=2",
#    "technology-tech-news":       "#{📁}technology-tech-news/id1448?mt=2"
  }


  desc "download categories"
  task download: :environment do
    CATEGORIES.each do |k,v|
      CSV.open("materials/categories/" + k.to_s + ".csv", "w") do |csv|
        ALPHABET.each do |letter|
          alpha_podcast_url = "#{v}&letter=#{letter}"

          # Determine how many pages there are, but no lower than 1.
          list_of_podcasts_doc = Nokogiri::HTML(open(alpha_podcast_url))
          number_of_pages = list_of_podcasts_doc.xpath("//*[@id='selectedgenre']/ul[3]/li/a").size || 1

          (1 .. number_of_pages).each do |i|
            url = alpha_podcast_url+"&page=#{i}"
            puts "#{k}, #{url}"
            csv << [k, url]
          end
        end
      end
    end
  end
end