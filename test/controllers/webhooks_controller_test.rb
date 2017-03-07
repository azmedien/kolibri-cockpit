require 'test_helper'

class WebhooksControllerTest < ActionDispatch::IntegrationTest
  test "should get receive" do
    get webhooks_receive_url
    assert_response :success
  end

end
