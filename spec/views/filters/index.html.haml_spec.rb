require 'spec_helper'

describe "filters/index" do
  before(:each) do
    assign(:filters, [
      stub_model(Filter,
        :name => "Name",
        :content => "Content",
        :scope => "Scope"
      ),
      stub_model(Filter,
        :name => "Name",
        :content => "Content",
        :scope => "Scope"
      )
    ])
  end

  it "renders a list of filters" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "Name".to_s, :count => 2
    assert_select "tr>td", :text => "Content".to_s, :count => 2
    assert_select "tr>td", :text => "Scope".to_s, :count => 2
  end
end
