class AddRejectedByEmployerColumnToApplicants < ActiveRecord::Migration[6.0]
  def change
    add_column :applicants, :rejected_email_sent, :boolean, default: false
  end
end
