class CreateJobs < ActiveRecord::Migration[6.0]
  def change
    create_table :jobs, id: :uuid do |t|
      t.string :title,    null: false
      t.string :category, null: false
      t.string :location, null: false
      t.integer :min_salary
      t.integer :max_salary
      t.string :employment_type, null: false
      t.string :status, limit: 10, null: false
      t.string :redirect_link
      t.references :user, type: :uuid, null: false

      t.timestamps
    end

    add_index :jobs, :title
    add_index :jobs, :category
    add_index :jobs, :location
  end
end
