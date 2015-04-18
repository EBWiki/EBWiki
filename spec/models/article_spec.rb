require 'rails_helper'

RSpec.describe Article, type: :model do
  describe "#new" do
    it "takes three parameters and returns an Article object" do
		article = build(:article)
        article.should be_an_instance_of Article
    end
  end

  describe "#title" do
    it "returns the correct title" do
	  	article = build(:article)
        expect(article.title).to eq "Title"
    end
  end

  describe "#content" do
    it "returns the correct content" do
	  	article = build(:article)
        expect(article.content).to eq "A new article"
    end
  end
end