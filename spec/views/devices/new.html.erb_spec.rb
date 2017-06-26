require 'rails_helper'

RSpec.describe "devices/new", type: :view do
  before(:each) do
    assign(:device, Device.new(
      :token => "MyString",
      :platform => 1
    ))
  end

  it "renders new device form" do
    render

    assert_select "form[action=?][method=?]", devices_path, "post" do

      assert_select "input#device_token[name=?]", "device[token]"

      assert_select "input#device_platform[name=?]", "device[platform]"
    end
  end
end
