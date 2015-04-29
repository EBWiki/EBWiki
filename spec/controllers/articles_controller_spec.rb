require 'rails_helper'

RSpec.describe ArticlesController, type: :controller do
  let(:articles) { FactoryGirl.create_list(:article, 4) }
  let(:state) {FactoryGirl.create(:state)}

  describe '#index' do
    before(:each) { get :index }

    it 'assigns all articles to @articles' do
      expect(assigns(:articles)).to match_array articles
    end

    it 'success' do
      expect(response).to be_success
    end
  end

  describe '#show' do
    context 'when requested article exists' do
      let(:article) { articles[rand 4] }
      before(:each) { get :show, id: article.id }

      it 'success' do
        expect(response).to be_success
      end

      it 'assigns it to @article' do
        expect(assigns(:article)).to eq article
      end
    end

    context 'when requested article does not exists' do
      it 'throws ActiveRecord::RecordNotFound' do
        expect { get :show, id: -1 }.to raise_exception ActiveRecord::RecordNotFound
      end
    end
  end

  describe '#create' do
    before(:each) { post :create, ** article_attrs }

    context 'when valid' do
      let(:article_attrs) { FactoryGirl.attributes_for(:article) }


      it 'success' do
        expect(response).to be_success
      end

      it 'saves and assigns new article to @article' do
        article = assigns(:article)

        expect(article).to be_kind_of ActiveRecord::Base
        expect(article).to be_persisted
        expect(articles).not_to include article
      end
    end

    context 'when invalid' do
      let(:article_attrs) { attributes_for(:invalid_article) }

      it 'fails' do
        expect(response).not_to be_success
      end

      it 'assigns article to @article' do
        expect(assigns(:article)).to be_kind_of ActiveRecord::Base
      end
    end
  end

  describe '#update' do
    let(:article) { create(:article) }
    before(:each) { patch :update, ** new_values, id: article.id }

    context 'when valid' do
      let(:new_values) { attributes_for(:article) }

      it 'success' do
        expect(response).to be_success
      end

      it 'saves and assigns article to @article' do
        expect(assigns(:article)).to eq article
      end

      it 'saves updates' do
        expect { article.reload }.to change { article.nick }.to(new_values[:nick])
      end
    end

    context 'when invalid' do
      let(:new_values) { attributes_for(:invalid_article) }

      it 'fails' do
        expect(response).not_to be_success
      end

      it 'assigns article to @article' do
        expect(assigns(:article)).to eq article
      end
    end
  end

  describe '#destroy' do
    context 'when requested article exists' do
      let(:article) { articles[rand 4] }
      before(:each) { delete :destroy, id: article.id }

      it 'success' do
        expect(response).to be_success
      end

      it 'removes article form DB' do
        expect(article.all).not_to include article
        expect { article.reload }.to raise_exception ActiveRecord::RecordNotFound
      end
    end

    context 'when requested article does not exists' do
      it 'throws ActiveRecord::RecordNotFound' do
        expect { delete :destroy, id: -1 }.to raise_exception ActiveRecord::RecordNotFound
      end
    end
  end
end
