class AddColumnsToCompanyTable < ActiveRecord::Migration[6.0]
  def change
    add_column :companies, :url,  :string
  end
end
