module WebhooksHelper
  include ActionView::Helpers::DateHelper
  include ActionView::Helpers::AssetTagHelper

  def build_to_html_table_row(app, build)
    if build.code < 0
      status = '<i class="fa fa-times-circle text-danger text-center" aria-hidden="true"></i>'
    else
      status = build.code == 0 ?
      '<i class="fa fa-circle-o-notch fa-spin text-primary text-center" ></i>' :
      '<i class="fa fa-check-circle text-success text-center"></i>'
    end

    meta = %{
      <span>#{build.platform.capitalize}</span></br>
      <span>
      #{build.platform == 'android' ? app.android_config['version_name'] : app.ios_config['version_name']}(
      #{build.platform == 'android' ? app.android_config['version_code'] : app.ios_config['version_code']})
      </span></br>
      <span>#{build.platform == 'android' ? app.android_config['bundle_id'] : app.ios_config['bundle_id']}</span>
    }

    html = %{
      <tr id="#{build.build_id}">
        <th scope="row">
          <a href="#{build.url}" target="_blank" data-toggle="tooltip" data-placement="left" data-html="true" title="#{meta}">
          #{image_tag(app.android_icon.url, size: "32", :class => "img-responsive rounded-circle") if app.android_icon?}
          </a></th>
        <th>#{status}</th>
        <td>#{build.stage.capitalize}</td>
        <td>#{build.message.capitalize}</td>
        <td>#{time_ago_in_words(build.updated_at)}</td>
      </tr>
    }

    html
  end
end
