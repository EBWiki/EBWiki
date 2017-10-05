# frozen_string_literal: true

PaperTrail::Rails::Engine.eager_load!

module PaperTrail
  class Version < ActiveRecord::Base
  end
end
