# frozen_string_literal: true

class CreateWorkExperiences < ActiveRecord::Migration[6.0]
  def change
    create_table :work_experiences, id: :uuid do |t|
      t.string :job_title, null: false
      t.string :company_name, null: false
      t.string :start_month, null: false
      t.integer :start_year, null: false
      t.string :finish_month
      t.integer :finish_year
      t.boolean :still_in_role
      t.text :description
      t.references :user, type: :uuid, null: false
      t.timestamps
    end
  end
end
