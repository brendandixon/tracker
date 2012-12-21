require 'spec_helper'

describe "stories/index" do
  before(:each) do
    assign(:stories, [
      stub_model(Story,
        :contact_us_link => "MyText",
        :title => "MyText",
        :service_id => 1
      ),
      stub_model(Story,
        :contact_us_link => "TheirText",
        :title => "TheirText",
        :service_id => 1
      )
    ])
  end

  it "renders a list of stories" do
    render
    expect(rendered).to match /MyText/
    expect(rendered).to match /TheirText/
  end
end
