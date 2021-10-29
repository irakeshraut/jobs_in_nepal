class CreateCompanies < ActiveRecord::Migration[6.0]
  def change
    create_table :companies, id: :uuid do |t|
      t.string :name, null: false
      t.string :phone, null: false
      t.text   :description
      t.timestamps
    end
  end
end
