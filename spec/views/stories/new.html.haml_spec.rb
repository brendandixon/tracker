require 'spec_helper'

describe "features/new" do
  before(:each) do
    assign(:feature, stub_model(Feature,
      :contact_us_link => "MyText",
      :title => "MyText",
      :service_id => 1
    ).as_new_record)
  end

  it "renders new feature form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => features_path, :method => "post" do
      assert_select "textarea#feature_contact_us_link", :name => "feature[contact_us_link]"
      assert_select "textarea#feature_title", :name => "feature[title]"
      assert_select "input#feature_service_id", :name => "feature[service_id]"
    end
  end
end
