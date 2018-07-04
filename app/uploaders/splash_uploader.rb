class SplashUploader < CarrierWave::Uploader::Base

  include CarrierWave::MiniMagick

  after :remove, :delete_empty_upstream_dirs

  version :xxxhdpi do
    process :resize_to_fill => [1280, 1920]
  end

  version :xxhdpi do
    process :resize_to_fill=> [960, 1600]
  end

  version :xhdpi do
    process :resize_to_fill => [720, 1280]
  end

  version :hdpi do
    process :resize_to_fill => [480, 800]
  end

  def store_dir
    "#{base_store_dir}/"
  end

  def base_store_dir
    "apps/#{model.internal_id}/assets"
  end

  def delete_empty_upstream_dirs
    path = ::File.expand_path(store_dir, root)
    Dir.delete(path) # fails if path not empty dir

    path = ::File.expand_path(base_store_dir, root)
    Dir.delete(path) # fails if path not empty dir

    # Delete 'assets' empty forlder for the app
    path = ::File.expand_path('..', path)
    Dir.delete(path) # fails if path not empty dir

    # Delete current app folder itself
    path = ::File.expand_path('..', path)
    Dir.delete(path) # fails if path not empty dir

  rescue SystemCallError
    true # nothing, the dir is not empty
  end

  def extension_whitelist
    %w(png)
  end

  def size_range
    0..2.megabytes
  end

  def filename
    name = File.extname(super) if !super.nil?
    mounted_as.to_s.chomp(name) + '.png' if name
  end
end
