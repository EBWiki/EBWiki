# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Comment, type: :model do

  it { should validate_presence_of(:content) }

  describe 'scopes' do
    let(:user) { create(:user) }
    let(:test_case) { create(:case) }
    let(:comments) { Comment.all }

    before(:each) { 3.times { |n| test_case.comments.create!(content: 'A comment', user: user) } }

    it 'returns comments sorted by desc create time' do
      query_result = Comment.sorted_by_creation(2).to_a
      expect(query_result).to eq(comments[1..2].reverse)
    end
  end
end
