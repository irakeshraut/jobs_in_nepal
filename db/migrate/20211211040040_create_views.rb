class CreateViews < ActiveRecord::Migration[6.0]
  def change
    create_table :views, id: :uuid do |t|
      t.string :ip, null: false
      t.references :job, null: false, type: :uuid

      t.timestamps
      t.index [:ip, :job_id], unique: true
    end
  end
end
