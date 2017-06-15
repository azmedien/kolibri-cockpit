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

  version :xxhdpi, :if => :icon? do
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

  # Provide a default URL as a default if there hasn't been a file uploaded:
  # def default_url
  #   # For Rails 3.1+ asset pipeline compatibility:
  #   # ActionController::Base.helpers.asset_path("fallback/" + [version_name, "default.png"].compact.join('_'))
  #
  #   "/images/fallback/" + [version_name, "default.png"].compact.join('_')
  # end

  # Process files as they are uploaded:
  # process scale: [200, 300]
  #
  # def scale(width, height)
  #   # do something
  # end

  # Create different versions of your uploaded files:
  # version :thumb do
  #   process resize_to_fit: [50, 50]
  # end

  # Add a white list of extensions which are allowed to be uploaded.
  # For images you might use something like this:
  def extension_whitelist
    %w(png svg)
  end

  def size_range
    0..2.megabytes
  end

  # Override the filename of the uploaded files:
  # Avoid using model.id or version_name here, see uploader/store.rb for details.
  def filename
    name = File.extname(super) if !super.nil?
    mounted_as.to_s.chomp(name) + '.png' if name
  end

  protected
  def icon?(new_file)
    mounted_as.to_s != 'splash'
  end

end
