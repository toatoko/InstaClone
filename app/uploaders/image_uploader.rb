class ImageUploader < CarrierWave::Uploader::Base
  # Include MiniMagick support for image processing
  include CarrierWave::MiniMagick

  # Use fog storage (S3)
  storage :fog

  # Override the directory where uploaded files will be stored.
  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  # Process main image - resize to reasonable size
  process resize_to_fill: [ 800, 600 ]

  # Create different versions of your uploaded files:
  version :thumb do
    process resize_to_fill: [ 150, 150 ]
  end

  # Create a small version for navbar/avatars
  version :small do
    process resize_to_fill: [ 70, 70 ]
  end

  # Add an allowlist of extensions which are allowed to be uploaded.
  def extension_allowlist
    %w[jpg jpeg gif png webp avif]
  end

  # Provide a default URL if no file uploaded
  def default_url(*args)
    "/images/fallback/" + [ version_name, "default.png" ].compact.join("_")
  end
end
