class CreateJoinTableShowsUsers < ActiveRecord::Migration[5.0]
  def change
    create_join_table :shows, :users do |t|
      t.index [:show_id, :user_id]
      t.index [:user_id, :show_id]
    end
  end
end
