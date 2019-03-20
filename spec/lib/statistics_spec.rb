# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Statistics do

  def mom_changed_cases_growth(start_cases:, end_cases:)
    Statistics.mom_changed_cases_growth(cases_at_start: start_cases, cases_at_end: end_cases)
  end

  def mom_cases_growth(start_cases:, end_cases:)
    Statistics.mom_cases_growth(cases_at_start: start_cases, cases_at_end: end_cases)
  end

  describe 'new case growth rate' do
    it 'returns the correct percentage increase' do
      FactoryBot.create(:case, date: 31.days.ago)
      FactoryBot.create(:case)
      expect(mom_changed_cases_growth(start_cases: Case.most_recent_occurrences(60.days.ago),
                                  end_cases: Case.most_recent_occurrences(30.days.ago))).to eq(0)
    end

    it 'returns 0 if no new cases in last 30 days' do
      FactoryBot.create(:case, date: 31.days.ago)
      expect(mom_changed_cases_growth(start_cases: Case.most_recent_occurrences(60.days.ago),
                                  end_cases: Case.most_recent_occurrences(30.days.ago))).to eq(0)
    end

    # What happens if there were new cases between 0-30 days ago but none 31-60 days ago?
    it 'returns correct percentage if previous 30 days period saw no new cases' do
      FactoryBot.create(:case, date: 10.days.ago)
      FactoryBot.create(:case, date: 15.days.ago)
      expect(mom_changed_cases_growth(start_cases: Case.most_recent_occurrences(60.days.ago),
                                  end_cases: Case.most_recent_occurrences(30.days.ago))).to eq(200)
    end
  end

  describe 'total case growth rate' do
    it 'returns the correct percentage increase' do
      FactoryBot.create(:case, created_at: 31.days.ago)
      FactoryBot.create(:case)
      expect(mom_cases_growth(start_cases: Case.all, end_cases: Case.created_this_month)).to eq(100)
    end

    it 'returns 0 if no created cases in last 30 days' do
      FactoryBot.create(:case, created_at: 31.days.ago)
      expect(mom_cases_growth(start_cases: Case.all, end_cases: Case.created_this_month)).to eq(0)
    end

    # What happens if all of the cases were created in the past 30 days?
    it 'returns correct percentage if all cases created in the past 30 days' do
      FactoryBot.create(:case, date: 10.days.ago)
      FactoryBot.create(:case, date: 15.days.ago)
      expect(mom_cases_growth(start_cases: Case.all, end_cases: Case.created_this_month)).to eq(200)
    end
  end

  describe 'updated case growth rate' do
    it 'returns the correct percentage increase' do
      case_one = FactoryBot.create(:case, updated_at: 41.days.ago)
      case_one.update(updated_at: 41.days.ago)
      FactoryBot.create(:case)
      expect(mom_changed_cases_growth(start_cases: Case.recently_updated(60.days.ago),
                                      end_cases: Case.recently_updated(30.days.ago))).to eq(0)
    end

    it 'returns 1 if no updates in last 30 days' do
      FactoryBot.create(:case, updated_at: 31.days.ago)
      expect(mom_changed_cases_growth(start_cases: Case.recently_updated(60.days.ago),
                                      end_cases: Case.recently_updated(30.days.ago))).to eq(100)
    end

    # What happens if there were updates between 0-30 days ago but none 31-60 days ago?
    it 'returns correct percentage if previous 30 days period saw no updates' do
      FactoryBot.create(:case, updated_at: 10.days.ago)
      expect(mom_changed_cases_growth(start_cases: Case.recently_updated(60.days.ago),
                                      end_cases: Case.recently_updated(30.days.ago))).to eq(100)
    end
  end
end