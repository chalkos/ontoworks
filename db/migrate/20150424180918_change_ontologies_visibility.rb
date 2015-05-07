class ChangeOntologiesVisibility < ActiveRecord::Migration
  def change
    remove_column :ontologies, :unlisted
    remove_column :ontologies, :extendable
    remove_column :ontologies, :expires

    add_column :ontologies, :public, :boolean, default: false
    add_column :ontologies, :shared, :boolean, default: false
  end
end
