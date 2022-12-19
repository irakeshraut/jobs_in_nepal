# frozen_string_literal: true

class SorceryCore < ActiveRecord::Migration[6.0]
  def change
    create_table :users, id: :uuid do |t|
      t.string :first_name, null: false
      t.string :last_name,  null: false
      t.string :role,       null: false
      t.string :email,      null: false
      t.string :crypted_password
      t.string :salt
      t.references :company, type: :uuid

      t.timestamps null: false
    end

    add_index :users, :email, unique: true
  end
end
