# frozen_string_literal: true

class AddColumsToApplicants < ActiveRecord::Migration[6.0]
  def change
    add_column :applicants, :status, :string, limit: 30
  end
end
