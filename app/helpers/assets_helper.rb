module AssetsHelper

  include ActionView::Helpers::AssetTagHelper

  def assets_content_type_icon(asset, size)
    case
    when asset.content_type.start_with?('image')
      image_tag(asset.file.url, size: size, :class => "img-responsive")
    when asset.content_type.end_with?('json')
      '<i class="fa fa-file-code-o" style="font-size:32px"></i>'
    else
      '<i class="fa fa-font" style="font-size:32px"></i>'
    end
  end

end
