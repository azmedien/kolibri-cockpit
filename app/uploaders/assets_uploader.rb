class AssetsUploader < CarrierWave::Uploader::Base

  include CarrierWave::MiniMagick

  after :remove, :delete_empty_upstream_dirs

  process :validate_dimensions, if: :image?
  process :convert_to_png, if: :image?
  process :save_content_type_and_size

  version :xxxhdpi, :if => :image? do
    convert :png
    process :resize_to_fit => [96, 96]
  end

  version :xxhdpi, :if => :image? do
    convert :png
    process :resize_to_fit => [72, 72]
  end

  version :xxhdpi, :if => :image? do
    convert :png
    process :resize_to_fit => [48, 48]
  end

  version :hdpi, :if => :image? do
    convert :png
    process :resize_to_fit => [36, 36]
  end

  version :x2, :if => :image? do
    convert :png
    process :resize_to_fit => [44, 44]
  end

  version :x3, :if => :image? do
    convert :png
    process :resize_to_fit => [88, 88]
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
    "#{base_store_dir}/assets"
  end

  def base_store_dir
    internal_id = model.internal_id(model.try(:app_id) || model.id)
    "apps/#{internal_id}"
  end

  def delete_empty_upstream_dirs
    path = ::File.expand_path(store_dir, root)
    Dir.delete(path) # fails if path not empty dir

    path = ::File.expand_path(base_store_dir, root)
    Dir.delete(path) # fails if path not empty dir

    # Delete current app folder itself
    path = ::File.expand_path('..', path)
    Dir.delete(path) # fails if path not empty dir

  rescue SystemCallError
    true # nothing, the dir is not empty
  end

  # Add a white list of extensions which are allowed to be uploaded.
  # For images you might use something like this:
  def extension_whitelist
    %w(png svg json xml otf ttf)
  end

  def size_range
    0..2.megabytes
  end

  # Override the filename of the uploaded files:
  # Avoid using model.id or version_name here, see uploader/store.rb for details.
  def filename
      ext = File.extname(super) if !super.nil?
      name = super.chomp(ext).parameterize.tr("-", "_") if ext

      if image? file
         name + '.png'
      else
        name + ext
      end
  end

  protected
  def image?(new_file)
    new_file.content_type.start_with? 'image' if !new_file.nil?
  end

  def save_content_type_and_size
    model.content_type = file.content_type == 'application/octet-stream' || file.content_type.blank? ? MIME::Types.type_for(original_filename).first : file.content_type
    model.file_size = file.size

    ext = File.extname(original_filename) if original_filename
    model.slug = original_filename.chomp(ext).parameterize.tr!("-", "_") if ext
  end

end
