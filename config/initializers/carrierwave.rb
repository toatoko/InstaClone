CarrierWave.configure do |config|
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

  config.fog_attributes = {}
end
