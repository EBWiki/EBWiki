# frozen_string_literal: true

require 'bundler/setup'
require_relative 'lib/photos_app'

root = __dir__
run PhotosApp.new(root: root)
