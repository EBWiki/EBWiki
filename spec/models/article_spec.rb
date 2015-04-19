require 'rails_helper'

  describe Article do
    it "is invalid without a title" do
      article = build(:article, title: nil)
      expect(article).to be_invalid
    end
    it "is invalid without a date" do
      article = build(:article, date: nil)
      expect(article).to be_invalid
    end
    it "is invalid without a state_id" do
      article = build(:article, state_id: nil)
      expect(article).to be_invalid
    end
   #  it "returns a sorted array of results that match" do
   #   smith = Article.create(
   #     title: 'John Smith',
   #     content: 'A new victim'
   #   )
   #   jones = Article.create(
   #     title: 'John Jones',
   #     content: 'A new victim'
   #   )
   #   james = Article.create(
   #     title: 'Jane James',
   #     content: 'A new victim'
   #   )
   #   smith.reindex
   #   jones.reindex
   #   james.reindex
   #   Article.searchkick_index.refresh
   #   expect(Article.find_by_search("John")).to eq [smith, jones]
   # end
  end

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