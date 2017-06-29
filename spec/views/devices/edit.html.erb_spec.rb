require 'rails_helper'

RSpec.describe "devices/edit", type: :view do
  before(:each) do
    @device = assign(:device, Device.create!(
      :token => "MyString",
      :platform => 1
    ))
  end

  it "renders the edit device form" do
    render

    assert_select "form[action=?][method=?]", device_path(@device), "post" do

      assert_select "input#device_token[name=?]", "device[token]"

      assert_select "input#device_platform[name=?]", "device[platform]"
    end
  end
end
