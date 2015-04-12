module PaperTrail
  class Version < ActiveRecord::Base
    attr_accessible :ip
  end
end