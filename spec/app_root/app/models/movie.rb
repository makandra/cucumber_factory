class Movie < ActiveRecord::Base

  belongs_to :prequel, :class_name => "Movie"
  belongs_to :reviewer, :class_name => "User"

  validate do |record|
    record.errors.add(:reviewer, 'may not be deleted') if record.reviewer and record.reviewer.deleted?
  end

end
