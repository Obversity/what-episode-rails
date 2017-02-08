class CreateUsers < ActiveRecord::Migration[5.0]
  def change
    create_table :users do |t|
      t.string :password
      t.string :salt
      t.string :username
      t.string :email
      t.string :token
      t.datetime :last_signed_in

      t.timestamps
    end
  end
end
