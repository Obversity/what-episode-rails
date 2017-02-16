class AddIndexToImbdIdOnEpisodes < ActiveRecord::Migration[5.0]
  def change
    add_index :episodes, :imdb_id, unique: true
  end
end
