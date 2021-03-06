# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CaseQuery do
  describe '.most_recent_as_of' do
    subject(:most_recent_as_of) { described_class.new.most_recent_as_of(date: date) }
    let(:date) { 15.days.ago }

    it 'returns, given a date, the cases available that day occurring within 30 days prior' do
      case_record = FactoryBot.create(:case, date: 20.days.ago)
      case_record.update(created_at: 17.days.ago)
      expect(most_recent_as_of.pluck(:title).first).to eq case_record.title
    end
  end

  describe '.created_by' do
    subject(:created_by) { described_class.new.created_by(date: date) }
    let(:date) { 15.days.ago }

    it 'returns, given a date, the cases created by that date' do
      case_record = FactoryBot.create(:case)
      case_record.update(created_at: 17.days.ago)
      expect(created_by.pluck(:title).first).to eq case_record.title
    end
  end

  describe '.recently_updated_as_of' do
    subject(:recently_updated_as_of) { described_class.new.recently_updated_as_of(date: date) }
    let(:date) { 15.days.ago }

    it 'returns, given a date, the cases available that day and updated within 30 days prior' do
      case_record = FactoryBot.create(:case, date: 20.days.ago)
      case_record.update(created_at: 17.days.ago, updated_at: 17.days.ago)
      expect(recently_updated_as_of.pluck(:title).first).to eq case_record.title
    end
  end
end
