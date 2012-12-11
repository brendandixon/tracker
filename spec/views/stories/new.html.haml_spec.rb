require 'spec_helper'

describe "stories/new" do
  before(:each) do
    assign(:story, stub_model(Story,
      :contact_us_number => "MyText",
      :title => "MyText",
      :service_id => 1
    ).as_new_record)
  end

  it "renders new story form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => stories_path, :method => "post" do
      assert_select "input#story_contact_us_number", :name => "story[contact_us_number]"
      assert_select "input#story_title", :name => "story[title]"
      assert_select "select#story_service_id", :name => "story[service_id]"
    end
  end
end
