class IconsUploader < CarrierWave::Uploader::Base

  include CarrierWave::MiniMagick

  after :remove, :delete_empty_upstream_dirs

  process :validate_dimensions
  process :convert_to_png

  version :xxxhdpi, :if => :icon? do
    convert :png
    process :resize_to_fit => [196, 196]
  end

  version :xxhdpi, :if => :icon? do
    convert :png
    process :resize_to_fit => [144, 144]
  end

  version :xhdpi, :if => :icon? do
    convert :png
    process :resize_to_fit => [96, 96]
  end

  version :hdpi, :if => :icon? do
    convert :png
    process :resize_to_fit => [72, 72]
  end

  def convert_to_png()
    manipulate! do |img|
      img.format("png") do |c|
        c.resize      "#{img[:width]}x#{img[:height]}>"
        c.resize      "#{img[:width]}x#{img[:height]}<"
        # Background workaround because of the commandline args arrangement
        c.args.unshift "none"
        c.args.unshift "-background"
        c.density      "512"
        c.args.unshift ".8"
        c.args.unshift "-sharpen"
      end
      file.content_type="image/png"

      img
    end
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
    %w(png svg)
  end

  def size_range
    0..2.megabytes
  end

  def filename
    name = File.extname(super) if !super.nil?
    mounted_as.to_s.chomp(name) + '.png' if name
  end

  protected
  def icon?(new_file)
    mounted_as.to_s != 'splash'
  end

end
