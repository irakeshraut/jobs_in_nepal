# frozen_string_literal: true

class CreateEducations < ActiveRecord::Migration[6.0]
  def change
    create_table :educations, id: :uuid do |t|
      t.string :institution_name, null: false
      t.string :course_name, null: false
      t.boolean :course_completed, null: false, default: true
      t.integer :finished_year
      t.string :expected_finished_month
      t.integer :expected_finished_year
      t.text :course_highlights
      t.references :user, type: :uuid, null: false
      t.timestamps
    end
  end
end
