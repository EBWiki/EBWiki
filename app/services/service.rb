# frozen_string_literal: true

module Service # rubocop:todo Style/Documentation
  extend ActiveSupport::Concern

  included do
    def self.call(*args)
      new.call(*args)
    end
  end
end
