# frozen_string_literal: true

class CreateBookmarks < ActiveRecord::Migration[6.0]
  def change
    create_table :bookmarks, id: :uuid do |t|
      t.references :user, null: false, type: :uuid
      t.references :job, null: false, type: :uuid
      t.timestamps
    end
  end
end
