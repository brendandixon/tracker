require 'spec_helper'

describe "features/edit" do
  before(:each) do
    @feature = assign(:feature, stub_model(Feature,
      :contact_us_link => "MyText",
      :title => "MyText",
      :service_id => 1
    ))
  end

  it "renders the edit feature form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => features_path(@feature), :method => "post" do
      assert_select "textarea#feature_contact_us_link", :name => "feature[contact_us_link]"
      assert_select "textarea#feature_title", :name => "feature[title]"
      assert_select "input#feature_service_id", :name => "feature[service_id]"
    end
  end
end
