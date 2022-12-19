# frozen_string_literal: true

class CreateViews < ActiveRecord::Migration[6.0]
  def change
    create_table :views, id: :uuid do |t|
      t.string :ip, null: false
      t.references :job, null: false, type: :uuid

      t.timestamps
      t.index %i[ip job_id], unique: true
    end
  end
end
