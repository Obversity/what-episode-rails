class CreateShows < ActiveRecord::Migration[5.0]
  def change
    create_table :shows do |t|
      t.string :title
      t.string :year
      t.string :image
      t.string :genre

      t.timestamps
    end
  end
end
