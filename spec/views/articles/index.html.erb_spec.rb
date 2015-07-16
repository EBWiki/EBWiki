require 'rails_helper'

RSpec.describe "articles/index.html.erb", type: :view do

  it "displays all the articles" do
    assign(:articles, Kaminari.paginate_array([
      FactoryGirl.create(:article, :title => "John Doe"),
      FactoryGirl.create(:article,:title => "Jimmy Doe")
    ]).page(1))

    render

    expect(rendered).to match /John Doe/m
    expect(rendered).to match /Jimmy Doe/m
  end
end