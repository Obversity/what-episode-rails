class CreateEpisodes < ActiveRecord::Migration[5.0]
  def change
    create_table :episodes do |t|
      t.integer :number
      t.string :title
      t.date :released
      t.string :imdb_id
      t.float :imdb_rating
      t.belongs_to :season

      t.timestamps
    end
  end
end
