class CreateUsers < ActiveRecord::Migration

  def self.up
    create_table :users do |t|
      t.string :email
      t.string :name
      t.boolean :deleted
      t.boolean :locked
      t.boolean :subscribed
      t.boolean :scared
      t.boolean :scared_by_spiders
      t.datetime :created_at
    end
  end

  def self.down
    drop_table :users
  end
  
end
