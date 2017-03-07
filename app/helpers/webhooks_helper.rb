module WebhooksHelper
  def build_to_html_table_row(build)

    hmtl = %{
      <tr id="#{build.build_id}">
        <th scope="row">#{build.build_id}</th>
        <td>#{build.build_status.capitalize}</td>
        <td>#{build.test_status.capitalize}</td>
        <td>#{build.publish_status.capitalize}</td>
        <td>#{build.updated_at}</td>
      </tr>
    }
  end
end
