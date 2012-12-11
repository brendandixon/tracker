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
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "MyText".to_s, :count => 1
    assert_select "tr>td", :text => "TheirText".to_s, :count => 1
  end
end
