# frozen_string_literal: true

PaperTrail::Rails::Engine.eager_load!

module PaperTrail
  class Version < ActiveRecord::Base
    PaperTrail.config.track_associations = false
  end
end
