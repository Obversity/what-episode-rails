class AddImbdIdToShows < ActiveRecord::Migration[5.0]
  def change
    add_column :shows, :imdb_id, :string
    add_index :shows, :imdb_id, unique: true
  end
end
