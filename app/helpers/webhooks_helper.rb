module WebhooksHelper
  include ActionView::Helpers::DateHelper
  include ActionView::Helpers::AssetTagHelper


  def send_build_update_cable build, stage, code, message
    build.stage = stage
    build.code = code
    build.message = message
    build.save!

    send_build_cable(build)
  end

  def send_cable(message, type)
    html = render_message(message, type)
    ActionCable.server.broadcast 'app_configure',
                                 html: html
  end

  def send_build_cable(build)
    ActionCable.server.broadcast 'webhooks',
      id: build.id,
      html: build_to_html_table_row(build.app, build),
      platform: build.platform
  end

  def build_to_html_table_row(app, build)

    is_finished = build.stage == 'publish' && build.code == 1
    url_literal = is_finished ? "Download files" : "Link to build"

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
      <tr id="#{build.id}" data-href="#{build.url}" target="_blank">
        <th scope="row" data-toggle="tooltip" data-placement="bottom" data-html="true" title="#{meta}">
          #{image_tag("placeholder.png", size: "32", :class => "img-fluid rounded-circle preload", data: {source: app.android_icon.url}) if app.android_icon?}
        </th>
        <th>#{status}</th>
        <th><a href="#{build.url}" target="_blank">#{url_literal}</a></th>
        <td>#{build.stage.capitalize}</td>
        <td data-toggle="tooltip" data-placement="bottom" data-html="true" title="#{build.message}">#{build.message.lines.first.capitalize}</td>
        <td data-toggle="tooltip" data-placement="bottom" title="#{build.updated_at}">#{time_ago_in_words(build.updated_at)}</td>
      </tr>
    }

    html
  end
end
