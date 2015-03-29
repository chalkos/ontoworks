class AddDescriptionToOntologies < ActiveRecord::Migration
  def change
    add_column :ontologies, :description, :text, null: true
  end
end
