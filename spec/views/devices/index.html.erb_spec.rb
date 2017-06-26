require 'rails_helper'

RSpec.describe "devices/index", type: :view do
  before(:each) do
    assign(:devices, [
      Device.create!(
        :token => "Token",
        :platform => 2
      ),
      Device.create!(
        :token => "Token",
        :platform => 2
      )
    ])
  end

  it "renders a list of devices" do
    render
    assert_select "tr>td", :text => "Token".to_s, :count => 2
    assert_select "tr>td", :text => 2.to_s, :count => 2
  end
end
