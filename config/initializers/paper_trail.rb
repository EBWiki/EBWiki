# frozen_string_literal: true

PaperTrail::Rails::Engine.eager_load!
PaperTrail.config.track_associations = false
module PaperTrail
  class Version < ActiveRecord::Base
  end
end
