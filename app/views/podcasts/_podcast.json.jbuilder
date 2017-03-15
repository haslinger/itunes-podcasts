json.extract! podcast, :id, :title, :category, :itunes_url, :feed_url, :failed, :created_at, :updated_at
json.url podcast_url(podcast, format: :json)
