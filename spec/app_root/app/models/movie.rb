class Movie < ActiveRecord::Base

  belongs_to :prequel, :class_name => "Movie"
  belongs_to :reviewer, :class_name => "User"

end
