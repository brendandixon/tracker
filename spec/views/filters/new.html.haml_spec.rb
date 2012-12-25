require 'spec_helper'

describe "filters/new" do
  before(:each) do
    assign(:filter, stub_model(Filter,
      :name => "MyString",
      :content => "MyString",
      :scope => "MyString"
    ).as_new_record)
  end

  it "renders new filter form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => filters_path, :method => "post" do
      assert_select "input#filter_name", :name => "filter[name]"
      assert_select "input#filter_content", :name => "filter[content]"
      assert_select "input#filter_scope", :name => "filter[scope]"
    end
  end
end
