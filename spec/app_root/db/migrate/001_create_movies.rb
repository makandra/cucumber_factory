class CreateMovies < ActiveRecord::Migration

  def self.up
    create_table :movies do |t|
      t.string :title
      t.integer :year
      t.integer :prequel_id
      t.integer :reviewer_id
    end
  end

  def self.down
    drop_table :movies
  end
  
end
