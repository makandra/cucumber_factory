class CreatePayments < ActiveRecord::Migration

  def self.up
    create_table :payments do |t|
      t.text :comment
      t.integer :amount
    end
  end

  def self.down
    drop_table :payments
  end
  
end
