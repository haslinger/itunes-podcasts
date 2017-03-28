class AddCompletedToPodcasts < ActiveRecord::Migration[5.0]
  def change
    add_column :podcasts, :done, :boolean
  end
end