class Opera < ActiveRecord::Base
  has_many :movies, as: :premiere_site, inverse_of: :premiere_site
end
