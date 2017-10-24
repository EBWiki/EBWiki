# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'articles/index.html.erb', type: :view do
  it 'displays all the articles' do
    assign(:articles, Kaminari.paginate_array([
                                                article1 = FactoryBot.build(:article, title: 'John Doe'),
                                                article2 = FactoryBot.build(:article, title: 'Jimmy Doe', state: State.where(ansi_code: 'NY').first)
                                              ]).page(1))

    render

    expect(rendered).to match /John Doe/m
    expect(rendered).to match /Jimmy Doe/m
  end
end
