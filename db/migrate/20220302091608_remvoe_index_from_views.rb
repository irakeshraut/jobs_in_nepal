class RemvoeIndexFromViews < ActiveRecord::Migration[6.0]
  def change
    remove_index :views, name: 'index_views_on_ip_and_job_id'
  end
end
