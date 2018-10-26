class User < ActiveRecord::Base

  has_many :reviewed_movies, class_name: 'Movie', foreign_key: 'reviewer_id'

end
