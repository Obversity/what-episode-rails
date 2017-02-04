class AddFlagCountToQuestion < ActiveRecord::Migration[5.0]
  def change
    add_column :questions, :flag_count, :integer
  end
end
