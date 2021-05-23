# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Comment, type: :model do

  it { should validate_presence_of(:content) }

  describe 'scopes' do
    it 'returns comments sorted by desc create time' do
      comment_one = FactoryBot.create(:comment)
      comment_two = FactoryBot.create(:comment)
      comment_three = FactoryBot.create(:comment)

      comments = Comment.sorted_by_creation 2
      expect(comments.to_a).to include(comment_three)
      expect(comments.to_a).to include(comment_two)
      expect(comments.to_a).not_to include(comment_one)
    end
  end
end
