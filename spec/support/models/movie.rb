class Movie < ActiveRecord::Base

  belongs_to :prequel, :class_name => "Movie"
  belongs_to :reviewer, :class_name => "User"
  belongs_to :uuid_reviewer, :class_name => "UuidUser"
  belongs_to :premiere_site, polymorphic: true, required: false

  validate do |record|
    record.errors.add(:reviewer, 'may not be deleted') if record.reviewer and record.reviewer.deleted?
  end

end
