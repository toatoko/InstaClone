# Replace your existing config/initializers/carrierwave.rb with this:

CarrierWave.configure do |config|
  if Rails.env.development? && ENV["USE_LOCAL_STORAGE"] == "true"
    # Local storage for development
    config.storage = :file
    config.enable_processing = true
    config.root = Rails.root
    config.cache_dir = "#{Rails.root}/tmp/uploads"
  else
    # S3 storage for production or when explicitly enabled
    config.fog_provider = "fog/aws"
    config.fog_credentials = {
      provider:              "AWS",
      aws_access_key_id:     ENV["AWS_ACCESS_KEY_ID"],
      aws_secret_access_key: ENV["AWS_SECRET_ACCESS_KEY"],
      region:                ENV["AWS_REGION"]
    }

    config.fog_directory  = ENV["FOG_DIRECTORY"]
    config.cache_dir      = "#{Rails.root}/tmp/uploads"
    config.storage        = :fog

    config.fog_attributes = {
      "x-amz-acl" => nil,
      "Cache-Control" => "public, max-age=31536000"
    }

    config.fog_public = true
  end
end
