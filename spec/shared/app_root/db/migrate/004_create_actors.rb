class CreateActors < ActiveRecord::Migration

  def self.up
    create_table :actors do |t|
    end
  end

  def self.down
    drop_table :actors
  end
  
end
