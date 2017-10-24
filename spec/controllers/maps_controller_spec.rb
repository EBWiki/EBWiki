# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MapsController, type: :controller do
  describe 'GET #index' do
    let!(:articles) do
      allow_any_instance_of(Article).to receive(:full_address).and_return('230 West 43rd St. New York City NY 10036')
      FactoryBot.create_list(:article, 20)
    end

    before do
      get :index
    end

    it 'returns http success' do
      expect(response).to have_http_status(:success)
    end

    it 'returns all articles' do
      expect(assigns[:articles].size).to be >= 20
    end

    describe 'each article' do
      let(:first_article) { assigns[:articles].first }

      it 'has an integer id as the first element of the array' do
        expect(first_article[0]).to be_a_kind_of(Integer)
      end

      it 'has a float for the latitude' do
        expect(first_article[1]).to be_a_kind_of(Float)
      end

      it 'has a float for the longitude' do
        expect(first_article[2]).to be_a_kind_of(Float)
      end

      it 'has a String for the title' do
        expect(first_article[4]).to be_a_kind_of(String)
      end

      it 'has a String for the overview' do
        expect(first_article[4]).to be_a_kind_of(String)
      end
    end
  end
end
