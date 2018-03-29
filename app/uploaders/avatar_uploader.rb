# frozen_string_literal: true

class AvatarUploader < CarrierWave::Uploader::Base
  # Include RMagick or MiniMagick support:
  # include CarrierWave::RMagick
  include CarrierWave::MiniMagick
  include CarrierWave::ImageOptimizer

  # Choose what kind of storage to use for this uploader:
  # storage :file
  storage :fog

  # Override the directory where uploaded files will be stored.
  # This is a sensible default for uploaders that are meant to be mounted:
  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  # Create different versions of your uploaded files:
  version :large_avatar do
    # returns a 150x150 image
    process resize_to_fill: [250, 250]
    process :optimize
  end
  version :medium_avatar do
    # returns a 50x50 image
    process resize_to_fill: [150, 150]
    process optimize: [{ quiet: true }]
  end
  version :small_avatar do
    # returns a 35x35 image
    process resize_to_fill: [35, 35]
    process optimize: [{ quiet: true }]
  end
  version :thumb do
    process resize_to_fill: [50, 50]
    process optimize: [{ quiet: true }]
  end

  # Add a white list of extensions which are allowed to be uploaded.
  # For images you might use something like this:
  def extension_white_list
    %w[jpg jpeg gif png]
  end
end
