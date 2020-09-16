class Payment < ActiveRecord::Base
  class AttachmentUploader < CarrierWave::Uploader::Base
    storage :file
  end

  mount_uploader :attachment, AttachmentUploader

  if ActiveRecord::VERSION::MAJOR <= 3
    # Only the comment is accessible, amount isn't
    attr_accessible :comment
  end

end
