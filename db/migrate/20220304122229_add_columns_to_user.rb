class AddColumnsToUser < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :profile_visible, :boolean, null: false, default: false
    add_column :users, :visible_resume_name, :string
  end
end
