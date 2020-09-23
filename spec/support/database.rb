Gemika::Database.new.rewrite_schema! do

  create_table :movies do |t|
    t.string :title
    t.integer :year
    t.integer :prequel_id
    t.integer :reviewer_id
    t.string :uuid_reviewer_id
    t.integer :box_office_result
    t.string :premiere_site_type
    t.bigint :premiere_site_id
  end

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

  create_table :uuid_users, :id => false do |t|
    t.string :id
    t.string :email
    t.string :name
    t.datetime :created_at
  end

  create_table :payments do |t|
    t.text :comment
    t.integer :amount
    t.string :attachment
  end

  create_table :actors do |t|
  end

  create_table :job_offers do |t|
  end

  create_table :operas do |t|
  end

end
