# frozen_string_literal: true

# Config settings for paper_trail gem
PaperTrail::Rails::Engine.eager_load!
PaperTrail.config.track_associations = true
module PaperTrail
  class Version < ActiveRecord::Base
    PaperTrail.config.track_associations = true
  end
end
