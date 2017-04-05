module WebhooksHelper
  def build_to_html_table_row(build)

    statuses = Array.new
    statuses << build.build_status << build.test_status << build.publish_status

    if statuses.include? 'failed'
      status = '<i class="fa fa-times-circle text-danger text-center" aria-hidden="true"></i>'
    else
      status = build.publish_status == 'not started' ?
      '<i class="fa fa-circle-o-notch fa-spin text-primary text-center" ></i>' :
      '<i class="fa fa-check-circle text-success text-center"></i>'
    end

    hmtl = %{
      <tr id="#{build.build_id}">
        <th scope="row"><a href="#{build.url}" target="_blank">#{build.build_id}</a></th>
        <th>#{status}</th>
        <td>#{build.build_status.capitalize}</td>
        <td>#{build.test_status.capitalize}</td>
        <td>#{build.publish_status.capitalize}</td>
        <td>#{build.updated_at}</td>
      </tr>
    }
  end
end
