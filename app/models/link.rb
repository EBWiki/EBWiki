# frozen_string_literal: true

class Link < ActiveRecord::Base
  belongs_to :article
end
