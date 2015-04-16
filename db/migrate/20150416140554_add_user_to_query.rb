class AddUserToQuery < ActiveRecord::Migration
  def change
    add_reference :queries, :user, index: true
    add_foreign_key :queries, :users
  end
end
