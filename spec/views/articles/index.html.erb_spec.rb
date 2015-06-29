require 'rails_helper'

RSpec.describe "articles/index.html.erb", type: :view do

  it "displays all the articles" do
    assign(:articles, [
      FactoryGirl.create(:article, :title => "John Doe"),
      FactoryGirl.create(:article,:title => "Jimmy Doe")
    ])

    render

    expect(rendered).to match /John Doe/m
    expect(rendered).to match /Jimmy Doe/m
  end
end