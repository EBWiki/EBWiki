# frozen_string_literal: true

PaperTrail::Rails::Engine.eager_load!
PaperTrail.config.track_associations = true
module PaperTrail
  class Version < ActiveRecord::Base
    PaperTrail.config.track_associations = true
  end
end
