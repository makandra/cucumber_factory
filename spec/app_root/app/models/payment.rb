class Payment < ActiveRecord::Base

  # Only the comment is accessible, amount isn't
  attr_accessible :comment

end
