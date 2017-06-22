class FirebaseUploader < CarrierWave::Uploader::Base

  def store_dir
    "#{base_store_dir}/"
  end

  def base_store_dir
    "apps/#{model.internal_id}/configs"
  end

  def extension_whitelist
    %w(json plist)
  end

  def size_range
    0..2.megabytes
  end

  def fog_public
    false
  end

  def fog_authenticated_url_expiration
    1.minutes # in seconds from now,  (default is 10.minutes)
  end
end
