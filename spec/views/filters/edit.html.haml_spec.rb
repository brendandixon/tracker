require 'spec_helper'

describe "filters/edit" do
  before(:each) do
    @filter = assign(:filter, stub_model(Filter,
      :name => "MyString",
      :content => "MyString",
      :scope => "MyString"
    ))
  end

  it "renders the edit filter form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => filters_path(@filter), :method => "post" do
      assert_select "input#filter_name", :name => "filter[name]"
      assert_select "input#filter_content", :name => "filter[content]"
      assert_select "input#filter_scope", :name => "filter[scope]"
    end
  end
end
