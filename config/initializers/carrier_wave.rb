require 'carrierwave/orm/activerecord'

module CarrierWave
  module MiniMagick
    def validate_dimensions
      manipulate! do |img|
        if img.dimensions.any?{|i| i > 4096 }
          raise CarrierWave::ProcessingError, "dimensions too large"
        end
        img
      end
    end
  end
end

CarrierWave.configure do |config|

  # Use local storage if in development or test
  if Rails.env.development? or Rails.env.test?
    CarrierWave.configure do |config|
      config.storage = :file
      config.cache_dir = '#{Rails.root}/public/tmp'
      config.ignore_processing_errors = true

      MiniMagick.logger.level = Logger::DEBUG
    end
  end

  if Rails.env.test? or Rails.env.cucumber?
  CarrierWave.configure do |config|
    config.enable_processing = false
  end
end

  # Use AWS storage if in production
  if Rails.env.production?
    CarrierWave.configure do |config|
      config.storage = :fog
      config.cache_dir = "#{Rails.root}/tmp/uploads"
    end
    
    config.fog_credentials = {
      :provider               => 'AWS',                             # required
      :aws_access_key_id      => ENV['S3_KEY'],                     # required
      :aws_secret_access_key  => ENV['S3_SECRET'],                  # required
      :region                 => ENV['S3_REGION']                   # optional, defaults to 'us-east-1'
    }
    config.fog_provider = 'fog/aws'
    config.fog_directory  = ENV['S3_BUCKET_NAME']                   # required
    #config.fog_host       = 'https://assets.example.com'           # optional, defaults to nil
    config.fog_public     = false                                   # optional, defaults to true
    config.fog_attributes = {'Cache-Control'=>'max-age=315576000'}  # optional, defaults to {}
  end
end
