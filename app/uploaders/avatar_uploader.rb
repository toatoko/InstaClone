class AvatarUploader < CarrierWave::Uploader::Base
  include CarrierWave::MiniMagick

  storage :fog

  # Create a thumbnail version for navbar
  version :thumb do
    process resize_to_fill: [70, 70] # 2x for retina
  end

  # Optional: create versions on upload, not on-demand
  process resize_to_fill: [200, 200]
end