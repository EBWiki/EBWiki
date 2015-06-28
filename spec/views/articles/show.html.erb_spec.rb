require 'rails_helper'

RSpec.describe "articles/show.html.erb", type: :view do
  it 'displays content field if content field is not blank' do
  	article = FactoryGirl.create(:article)

  	render
  	expect(rendered).to match /new article/
  end
end