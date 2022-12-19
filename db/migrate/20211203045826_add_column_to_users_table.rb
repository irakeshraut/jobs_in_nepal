# frozen_string_literal: true

class AddColumnToUsersTable < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :phone_no, :string
  end
end
