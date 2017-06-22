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
      #{build.platform.capitalize}
      #{build.platform == 'android' ? app.android_config['version_name'] : app.ios_config['version_name']}(#{build.platform == 'android' ? app.android_config['version_code'] : app.ios_config['version_code']})
      #{build.platform == 'android' ? app.android_config['bundle_id'] : app.ios_config['bundle_id']}
    }

    html = %{
      <tr id="#{build.build_id}" data-href="#{build.url}" target="_blank">
        <th scope="row" data-toggle="tooltip" data-placement="bottom" data-html="true" title="#{meta}">
          #{image_tag(app.android_icon.url, size: "32", :class => "img-responsive rounded-circle") if app.android_icon?}
        </th>
        <th>#{status}</th>
        <td>#{build.stage.capitalize}</td>
        <td data-toggle="tooltip" data-placement="bottom" data-html="true" title="#{build.message}">#{build.message.lines.first.capitalize}</td>
        <td data-toggle="tooltip" data-placement="bottom" title="#{build.updated_at}">#{time_ago_in_words(build.updated_at)}</td>
      </tr>
    }

    html
  end
end
