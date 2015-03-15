class CreateOntologies < ActiveRecord::Migration
  def change
    create_table :ontologies do |t|
      t.string :name
      t.string :directory

      t.timestamps null: false
    end
  end
end
