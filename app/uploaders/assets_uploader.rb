class AssetsUploader < CarrierWave::Uploader::Base

  include CarrierWave::MiniMagick

  process :validate_dimensions, if: :image?
  process :convert_to_png, if: :image?

  version :xxxhdpi, :if => :image? do
    process :resize_to_fit => [96, 96]
  end
  version :xxhdpi, :if => :image? do
    process :resize_to_fit => [72, 72]
  end
  version :xxhdpi, :if => :image? do
    process :resize_to_fit => [48, 48]
  end
  version :hdpi, :if => :image? do
    process :resize_to_fit => [36, 36]
  end
  version :mdpi, :if => :image? do
    process :resize_to_fit => [24, 24]
  end

  def convert_to_png()
    manipulate! do |img|
      img.format("png") do |c|
        c.resize      "#{img[:width]}x#{img[:height]}>"
        c.resize      "#{img[:width]}x#{img[:height]}<"
        c.transparent  "white"
      end
      img
    end
  end

  # convert collection-active.svg -resize 92x84> -resize 92x84< -background #000 out.png

  # Override the directory where uploaded files will be stored.
  # This is a sensible default for uploaders that are meant to be mounted:
  def store_dir
    "uploads/app/#{model.try(:app_id) || model.id}/#{model.class.to_s.underscore}/#{model.id}"
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
    %w(png svg json xml)
  end

  def size_range
    0..2.megabytes
  end

  protected

  def image?(new_file)
    new_file.content_type.start_with? 'image'
  end

  def is_square?(new_file)
    image = MiniMagick::Image.open(new_file.path)
    image[:width] == image[:height]
  end

  # Override the filename of the uploaded files:
  # Avoid using model.id or version_name here, see uploader/store.rb for details.
  def filename
      if image? file
        super.chomp(File.extname(super)) + '.png'
      else
        original_filename
      end
  end

end
