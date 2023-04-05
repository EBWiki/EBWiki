require "paper_trail/version"
require "paper_trail/version_concern"

PaperTrail::Rails::Engine.eager_load!
include PaperTrail::VersionConcern
module PaperTrail
  class Version < ActiveRecord::Base
    PaperTrail.config.track_associations = true
  end
end
PaperTrail.config.track_associations = true
