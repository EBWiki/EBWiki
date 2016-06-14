require 'rails_helper'

describe Article, :versioning => true do
  it "is invalid without a date" do
    article = build(:article, date: nil)
    expect(article).to be_invalid
  end

  it "is invalid without a state_id" do
    article = build(:article, state_id: nil)
    expect(article).to be_invalid
  end

  it 'is invalid without a subject' do
    article = create(:article)
    article.subjects = []
    expect(article).to be_invalid
  end

  it "is invalid without a summary" do
    article = build(:article, summary: nil)
    expect(article).to be_invalid
  end

  it 'starts versioning when a new article is created' do
    article = FactoryGirl.create(:article)
    expect(article.versions.size).to eq 1
    expect(article.versions[0].event).to eq 'create'
  end
  it 'adds a version when the title is changed' do
    article = FactoryGirl.create(:article)
    article.update_attribute(:title, "A New Title")
    expect(article.versions.size).to eq 2
  end
  it 'adds a version when the overview is changed' do
    article = FactoryGirl.create(:article)
    article.update_attribute(:overview, "An Old Article")
    expect(article.versions.size).to eq 2
  end
  it 'adds a version when the date is changed' do
    article = FactoryGirl.create(:article)
    article.update_attribute(:date, Date.yesterday)
    expect(article.versions.size).to eq 2
  end
  it 'adds a version when the city is changed' do
    article = FactoryGirl.create(:article)
    article.update_attribute(:city, "New Jack City")
    expect(article.versions.size).to eq 2
  end
  it 'adds a version when the avatar is changed' do
    article = FactoryGirl.create(:article)
    article.update_attribute(:avatar, "new_avatar")
    expect(article.versions.size).to eq 2
  end
  it 'adds a version when the video url is changed' do
    article = FactoryGirl.create(:article)
    article.update_attribute(:video_url, "new_video.com")
    expect(article.versions.size).to eq 2
  end
  it 'adds a version when the slug is changed' do
    article = FactoryGirl.create(:article)
    article.update_attribute(:slug, "joel-osteen")
    expect(article.versions.size).to eq 2
  end
  it 'does not add a version when the attribute is the same' do
    article = FactoryGirl.create(:article, title: "The Title")
    article.update_attribute(:title, "The Title")
    expect(article.versions.size).to eq 1
  end
  it 'copies the article.summary attribute to version.comment' do
    article = FactoryGirl.create(:article, title: "The Title")
    article.update_attributes(:title => "The Title has changed", :summary => "fixed the title")
    expect(article.versions.last.comment).to eq "fixed the title"
  end

  it 'adds city to slug to maintain uniqueness' do
    article = FactoryGirl.create(:article, title: "The Title")
    article2 = FactoryGirl.create(:article, title: "The Title")
    expect(article2.slug).to eq "the-title-albany"
  end

  it 'updates slug if article title is updated' do
    article = FactoryGirl.create(:article, title: "The Title")
    article.slug = nil
    article.title = "Another Title"
    article.save!
    article.reload
    expect(article.slug).to eq "another-title"
  end

end

describe "#new" do
  it "takes three parameters and returns an Article object" do
  article = build(:article)
      expect(article).to be_an_instance_of Article
  end
end

describe "#title" do
  it "returns the correct title" do
    article = build(:article)
      expect(article.title).to include "Title"
  end
end

describe "follower_count" do
  it "gives the correct followers count" do
    article = FactoryGirl.create(:article, id: 10)
    FactoryGirl.create(:follow, followable_id: 10)
    expect(article.followers.count).to eq(1)
  end
  it "has a zero counter cache to start" do
    article = FactoryGirl.create(:article)
    expect(Article.last.follows_count).to eq(0)
  end
  # it "has a counter cache" do
  #   article = FactoryGirl.create(:article)
  #   expect {
  #     article.follows.create(follower_id: 1, followable_id: article.id, followable_type: "Article", follower_type: "User")
  #   }.to change { article.reload.follows_count }.by(1)
  # end
end

describe "#content" do
  it "returns the correct content" do
    article = build(:article)
      expect(article.overview).to eq "A new article"
  end
end

describe "geocoded" do
  it "has a latitude" do
    article = FactoryGirl.create(:article)
      expect(article.latitude).not_to be_nil
  end
  it "has a longitude" do
    article = FactoryGirl.create(:article)
      expect(article.longitude).not_to be_nil
  end
end

describe "#nearby_cases" do
  describe "on success" do
    it "returns an empty array if no cases are nearby" do
      article = FactoryGirl.create(:article)
      expect(article.nearby_cases).to be_empty
    end
  end
  describe "on failure" do
    it "does not raise an error if the nearbys method returns nil" do
      article = FactoryGirl.create(:article)
      allow(article).to receive(:nearbys).and_return(nil)
      expect{article.nearby_cases}.not_to raise_error
    end
  end
end

describe "recently updated cases" do
  it "returns only cases updated in past 30 days" do
    article = FactoryGirl.create(:article, updated_at: 31.days.ago)
    article2 = FactoryGirl.create(:article)
    article2.update_attribute(:video_url, "new_video.com")
    expect(Article.first.cases_updated_last_30_days).to eq(1)
  end
end

describe "growth_in_case_updates" do
  it "returns correct percentage increase" do
    article = FactoryGirl.create(:article, updated_at: 31.days.ago)
    article2 = FactoryGirl.create(:article)
    article3 = FactoryGirl.create(:article, updated_at: 10.days.ago)
    article2.update_attribute(:video_url, "new_video.com")
    expect(Article.first.mom_growth_in_case_updates).to eq(100)
  end
end

describe "recent case growth rate" do
  it "returns the correct percentage increase" do
    article = FactoryGirl.create(:article, date: 31.days.ago)
    article2 = FactoryGirl.create(:article)
    expect(Article.first.mom_new_cases_growth).to eq(0)
  end
end

describe "total case growth rate" do
  it "returns the correct percentage increase" do
    article = FactoryGirl.create(:article, created_at: 31.days.ago)
    article2 = FactoryGirl.create(:article)
    expect(Article.first.mom_cases_growth).to eq(100)
  end
end