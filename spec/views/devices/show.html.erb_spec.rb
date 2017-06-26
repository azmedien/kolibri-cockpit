require 'rails_helper'

RSpec.describe "devices/show", type: :view do
  before(:each) do
    @device = assign(:device, Device.create!(
      :token => "Token",
      :platform => 2
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/Token/)
    expect(rendered).to match(/2/)
  end
end
