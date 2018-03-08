module Service
  extend ActiveSupport::Concern

  included do
    def self.call(*args)
      new.call(*args)
    end
  end
end
