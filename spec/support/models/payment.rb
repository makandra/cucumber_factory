class Payment < ActiveRecord::Base

  if ActiveRecord::VERSION::MAJOR <= 3
    # Only the comment is accessible, amount isn't
    attr_accessible :comment
  end

end
