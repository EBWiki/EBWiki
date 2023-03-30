# frozen_string_literal: true

# Config settings for paper_trail gem
# PaperTrail::Rails::Engine.eager_load!
include PaperTrail::VersionConcern
module PaperTrail
  class Version < ActiveRecord::Base
    PaperTrail.config.track_associations = true
  end
end
