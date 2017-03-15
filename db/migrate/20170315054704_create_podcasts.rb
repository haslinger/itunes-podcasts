class CreatePodcasts < ActiveRecord::Migration[5.0]
  def change
    create_table :podcasts do |t|
      t.string :title
      t.string :category
      t.string :itunes_url
      t.string :feed_url
      t.boolean :failed

      t.timestamps
    end
  end
end
