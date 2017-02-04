class CreateQuestions < ActiveRecord::Migration[5.0]
  def change
    create_table :questions do |t|
      t.belongs_to :episode, foreign_key: true
      t.string :event

      t.timestamps
    end
  end
end
