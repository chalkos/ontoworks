class AddDescToOntologies < ActiveRecord::Migration
  def change
    add_column :ontologies, :desc, :text
  end
end
