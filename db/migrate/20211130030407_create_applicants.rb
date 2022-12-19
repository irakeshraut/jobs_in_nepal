# frozen_string_literal: true

class CreateApplicants < ActiveRecord::Migration[6.0]
  def change
    create_table :applicants, id: :uuid do |t|
      t.string :resume_name
      t.string :cover_letter_name
      t.references :job, type: :uuid
      t.references :user, type: :uuid
      t.timestamps
    end
  end
end
