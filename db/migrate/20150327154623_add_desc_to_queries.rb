class AddDescToQueries < ActiveRecord::Migration
  def change
    add_column :queries, :desc, :text
  end
end
