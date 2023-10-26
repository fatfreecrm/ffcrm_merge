class CreateAccountAliases < ActiveRecord::Migration[4.2]
  def self.up
    create_table :account_aliases do |t|
      t.integer :account_id
      t.integer :destroyed_account_id

      t.timestamps
    end
  end

  def self.down
    drop_table :account_aliases
  end
end

