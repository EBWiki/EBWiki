# frozen_string_literal: true

module Service
  extend ActiveSupport::Concern

  included do
    def self.call(*, **kwargs)
      if kwargs.any?
        new.call(**kwargs)
      else
        new.call(*)
      end
    end
  end
end
