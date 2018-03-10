# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CasesHelper, type: :helper do
  let(:youtube_url) { I18n.t 'cases_helper.youtube_helper_url' }
  let(:vimeo_url) { I18n.t 'cases_helper.vimeo_helper_url' }
  let(:youtube_iframe_url) { I18n.t 'cases_helper.youtube_iframe_url' }
  let(:vimeo_iframe_url) { I18n.t 'cases_helper.vimeo_iframe_url' }
  describe '#embed' do
    it 'returns an empty string if the video URL is blank' do
      expect(helper.embed(youtube_url)).to eql(youtube_iframe_url)
    end

    it 'returns a content tag if youtube video URL is provided' do
      expect(helper.embed(youtube_url)).to eql(youtube_iframe_url)
    end

    it 'returns a content tag if vimeo video URL is provided' do
      expect(helper.embed(vimeo_url)).to eql(vimeo_iframe_urlq)
    end
  end

  # These specs confirm that the article_sanity_check works as expected
  # If there is data that is not available, then the sanity_check returns
  # false. At that point, the site can throw an error or redirect to
  # another page. This is a more graceful solution that making the error
  # page available.

  describe '#case_sanity_check' do
    it 'returns true if all the instance variables needed for the case are present' do
      this_case = FactoryBot.create(:case, community_action: 'community text')
      assign(:case, this_case)
      assign(:commentable, this_case)
      assign(:comment, Comment.new)
      assign(:subjects, this_case.subjects)
      expect(helper.case_sanity_check).to be_truthy
    end

    it 'returns false if any of the instance variables needed for the article are not present' do
      this_case = FactoryBot.create(:case, community_action: 'community text')
      assign(:case, this_case)
      assign(:commentable, this_case)
      assign(:comment, Comment.new)
      expect(helper.case_sanity_check).to be_falsey
    end
  end
end
