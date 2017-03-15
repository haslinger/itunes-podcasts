# sort files and make podcasts unique

CATEGORIES =  [:arts, :business, :comedy, :education, :games_and_hobbies,
               :government_and_organizations, :health, :kids_and_family, :music, :news_and_politics,
               :religion_and_spirituality, :science_and_medicine, :society_and_culture,
               :sports_and_recreation, :tv_and_film, :technology]

CATEGORIES.each do |category|
  %x( sort "podcasts/itunes-podcast-lists-#{category.to_s}.csv" | uniq -u > "podcasts/#{category.to_s}.csv" )
  %x( rm "podcasts/itunes-podcast-lists-#{category.to_s}.csv" )
end