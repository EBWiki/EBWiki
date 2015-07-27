require 'rails_helper'

RSpec.describe "articles/index.html.erb", type: :view do

  it "displays all the articles" do
    assign(:articles, Kaminari.paginate_array([
      article1 = FactoryGirl.create(:article, :title => "John Doe"),
      article2 = FactoryGirl.create(:article, :title => "Jimmy Doe")
    ]).page(1))
    article1.state = FactoryGirl.create(:state)
    article2.state = article1.state

    render

    expect(rendered).to match /John Doe/m
    expect(rendered).to match /Jimmy Doe/m
  end
end