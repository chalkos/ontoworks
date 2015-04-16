class AddUserToOntology < ActiveRecord::Migration
  def change
    add_reference :ontologies, :user, index: true
    add_foreign_key :ontologies, :users
  end
end
