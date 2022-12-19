# frozen_string_literal: true

class RemoveColumnFromCompanies < ActiveRecord::Migration[6.0]
  def change
    remove_column :companies, :description
  end
end
