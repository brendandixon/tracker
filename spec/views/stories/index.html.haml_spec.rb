require 'spec_helper'

describe "features/index" do
  before(:each) do
    assign(:features, [
      stub_model(Feature,
        :contact_us_link => "MyText",
        :title => "MyText",
        :service_id => 1
      ),
      stub_model(Feature,
        :contact_us_link => "TheirText",
        :title => "TheirText",
        :service_id => 1
      )
    ])
  end

  it "renders a list of features" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "MyText".to_s, :count => 2
    assert_select "tr>td", :text => "TheirText".to_s, :count => 2
    assert_select "tr>td", :text => 1.to_s, :count => 2
  end
end
