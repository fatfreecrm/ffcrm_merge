class CreateContactAliases < ActiveRecord::Migration[4.2]
  def self.up
    create_table :contact_aliases do |t|
      t.integer :contact_id
      t.integer :destroyed_contact_id

      t.timestamps
    end
  end

  def self.down
    drop_table :contact_aliases
  end
end

