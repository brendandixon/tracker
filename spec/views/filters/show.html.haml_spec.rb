require 'spec_helper'

describe "filters/show" do
  before(:each) do
    @filter = assign(:filter, stub_model(Filter,
      :name => "Name",
      :content => "Content",
      :scope => "Scope"
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/Name/)
    rendered.should match(/Content/)
    rendered.should match(/Scope/)
  end
end
