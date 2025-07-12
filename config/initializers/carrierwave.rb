CarrierWave.configure do |config|
  if Rails.env.production?
    config.storage = :fog
    # keep fog credentials here if needed
  else
    config.storage = :file
    config.enable_processing = true
  end
end
