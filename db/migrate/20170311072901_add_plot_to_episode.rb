class AddPlotToEpisode < ActiveRecord::Migration[5.0]
  def change
    add_column :episodes, :plot, :text
    add_column :episodes, :image_url, :text
  end
end
