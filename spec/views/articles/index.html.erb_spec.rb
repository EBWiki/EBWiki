# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'articles/index.html.erb', type: :view do
  it 'displays all the articles' do
    article1 = FactoryBot.build(:article, title: 'John Doe')
    article2 = FactoryBot.build(:article,
                                 title: 'Jimmy Doe',
                                 state: State.where(ansi_code: 'NY').first)
    assign(:articles, Kaminari.paginate_array([article1, article2]).page(1))

    assign(:recently_updated_articles, Article.sorted_by_update(2) )
    render

    expect(rendered).to match /John Doe/m
    expect(rendered).to match /Jimmy Doe/m
  end
end
