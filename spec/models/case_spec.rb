# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Case, type: :model, versioning: true do

  describe "validity" do
    it 'is invalid without a date' do
      this_case = build(:case, date: nil)
      expect(this_case).to be_invalid
    end

    it 'is invalid without a state_id' do
      this_case = build(:case, state_id: nil)
      expect(this_case).to be_invalid
    end

    it 'is invalid without a subject' do
      this_case = create(:case)
      this_case.subjects = []
      expect(this_case).to be_invalid
    end

    it 'is invalid without a summary' do
      this_case = build(:case, summary: nil)
      expect(this_case).to be_invalid
    end
  end

  describe "versioning" do
    it 'starts versioning when a new this_case is created' do
      this_case = FactoryBot.create(:case)
      expect(this_case.versions.size).to eq 1
      expect(this_case.versions[0].event).to eq 'create'
    end

    it 'adds a version when the title is changed' do
      this_case = FactoryBot.create(:case)
      this_case.update_attribute(:title, 'A New Title')
      expect(this_case.versions.size).to eq 2
    end

    it 'adds a version when the overview is changed' do
      this_case = FactoryBot.create(:case)
      this_case.update_attribute(:overview, 'An Old Case')
      expect(this_case.versions.size).to eq 2
    end

    it 'adds a version when the date is changed' do
      this_case = FactoryBot.create(:case)
      this_case.update_attribute(:date, Date.yesterday)
      expect(this_case.versions.size).to eq 2
    end

    it 'adds a version when the city is changed' do
      this_case = FactoryBot.create(:case)
      this_case.update_attribute(:city, 'Buffalo')
      expect(this_case.versions.size).to eq 2
    end

    it 'adds a version when the avatar is changed' do
      this_case = FactoryBot.create(:case)
      this_case.update_attribute(:avatar, 'new_avatar')
      expect(this_case.versions.size).to eq 2
    end

    it 'adds a version when the video url is changed' do
      this_case = FactoryBot.create(:case)
      this_case.update_attribute(:video_url, 'new_video.com')
      expect(this_case.versions.size).to eq 2
    end

    it 'adds a version when the slug is changed' do
      this_case = FactoryBot.create(:case)
      this_case.update_attribute(:slug, 'joel-osteen')
      expect(this_case.versions.size).to eq 2
    end

    it 'does not add a version when the attribute is the same' do
      this_case = FactoryBot.create(:case, title: 'The Title')
      this_case.update_attribute(:title, 'The Title')
      expect(this_case.versions.size).to eq 1
    end

    it 'copies the this_case.summary attribute to version.comment' do
      this_case = FactoryBot.create(:case, title: 'The Title')
      this_case.update_attributes(title: 'The Title has changed', summary: 'fixed the title')
      expect(this_case.versions.last.comment).to eq 'fixed the title'
    end
  end

  describe "slugs" do
    it 'adds city to slug to maintain uniqueness' do
      this_case = FactoryBot.create(:case, title: 'The Title')
      this_case2 = FactoryBot.create(:case, title: 'The Title')
      expect(this_case2.slug).to eq 'the-title-albany'
      expect(this_case.slug).not_to eq this_case2.slug
    end

    it 'updates slug if this_case title is updated' do
      this_case = FactoryBot.create(:case, title: 'The Title')
      this_case.slug = nil
      this_case.title = 'Another Title'
      this_case.save!
      this_case.reload
      expect(this_case.slug).to eq 'another-title'
    end
  end

  describe '#new' do
    it 'takes three parameters and returns an Case object' do
      this_case = build(:case)
      expect(this_case).to be_an_instance_of Case
    end
  end

  describe '#title' do
    it 'returns the correct title' do
      this_case = build(:case)
      expect(this_case.title).to include 'Title'
    end
  end

  describe 'follower_count' do
    it 'gives the correct followers count' do
      this_case = FactoryBot.create(:case, id: 10)
      FactoryBot.create(:follow, followable_id: 10)
      expect(this_case.followers.count).to eq(1)
    end

    it 'has a zero counter cache to start' do
      this_case = FactoryBot.create(:case)
      expect(Case.last.follows_count).to eq(0)
    end

    it 'has a counter cache' do
      this_case = FactoryBot.create(:case)
      expect do
        this_case.follows.create(follower_id: 1, followable_id: this_case.id, followable_type: 'Case', follower_type: 'User')
      end.to change { this_case.reload.follows_count }.by(1)
    end
  end

  describe '#content' do
    it 'returns the correct content' do
      this_case = build(:case)
      expect(this_case.overview).to eq 'A new case'
    end
  end

  describe 'geocoded' do
    it 'generates longitude and latitude from city and state on save' do
      this_case = FactoryBot.create(:case)
      expect(this_case.latitude).to be_a(Float)
      expect(this_case.longitude).to be_a(Float)
    end

    it 'updates geocoded coordinates when relevant fields are updated' do
      this_case = FactoryBot.create(:case)
      ohio = FactoryBot.create(:state_ohio)

      expect do
        this_case.update_attributes(city: 'Worthington',
                                  state_id: ohio.id,
                                  address: '1867 Irving Road',
                                  zipcode: '43085')
      end.to change { this_case.latitude }
    end
  end

  describe '#nearby_cases' do
    it 'returns an empty array if no cases are nearby' do
      this_case = FactoryBot.create(:case)
      expect(this_case.nearby_cases).to be_empty
    end

    it 'does not raise an error if the nearbys method returns nil' do
      this_case = FactoryBot.create(:case)
      allow(this_case).to receive(:nearbys).and_return(nil)
      expect { this_case.nearby_cases }.not_to raise_error
    end
  end

  describe 'recently updated cases' do
    it 'returns only cases updated in past 30 days' do
      this_case = FactoryBot.create(:case, updated_at: 31.days.ago)
      this_case2 = FactoryBot.create(:case)
      this_case2.update_attribute(:video_url, 'new_video.com')
      expect(Case.first.cases_updated_last_30_days).to eq(1)
    end
  end

  describe 'growth' do
    describe 'growth_in_case_updates' do
      it 'returns the correct percentage increase' do
        this_case = FactoryBot.create(:case, updated_at: 31.days.ago)
        this_case2 = FactoryBot.create(:case)
        this_case3 = FactoryBot.create(:case, updated_at: 10.days.ago)
        this_case2.update_attribute(:video_url, 'new_video.com')
        expect(Case.first.mom_growth_in_case_updates).to eq(100)
      end

      it 'returns 0 if no updates in last 30 days' do
        this_case = FactoryBot.create(:case, updated_at: 31.days.ago)
        expect(this_case.first.mom_growth_in_case_updates).to eq(0)
      end

      # What happens if there were updates between 0-30 days ago but none 31-60 days ago?
      it 'returns correct percentage if previous 30 days period saw no updates' do
        this_case = FactoryBot.create(:case, updated_at: 10.days.ago)
        expect(Case.first.mom_growth_in_case_updates).to eq(100)
      end
    end

    describe 'new case growth rate' do
      it 'returns the correct percentage increase' do
        this_case = FactoryBot.create(:case, date: 31.days.ago)
        this_case2 = FactoryBot.create(:case)
        expect(Case.first.mom_new_cases_growth).to eq(0)
      end

      it 'returns 0 if no new cases in last 30 days' do
        this_case = FactoryBot.create(:case, date: 31.days.ago)
        expect(Case.first.mom_new_cases_growth).to eq(0)
      end

      # What happens if there were new cases between 0-30 days ago but none 31-60 days ago?
      it 'returns correct percentage if previous 30 days period saw no new cases' do
        case_one = FactoryBot.create(:case, date: 10.days.ago)
        case_two = FactoryBot.create(:case, date: 15.days.ago)
        expect(Case.first.mom_new_cases_growth).to eq(200)
      end
    end

    describe 'total case growth rate' do
      it 'returns the correct percentage increase' do
        case_one = FactoryBot.create(:case, created_at: 31.days.ago)
        case_two = FactoryBot.create(:case)
        expect(Case.first.mom_cases_growth).to eq(100)
      end

      it 'returns 0 if no created cases in last 30 days' do
        this_case = FactoryBot.create(:case, created_at: 31.days.ago)
        expect(Case.first.mom_cases_growth).to eq(0)
      end

      #What happens if all of the cases were created in the past 30 days?
      it 'returns correct percentage if all cases created in the past 30 days' do
        case_one = FactoryBot.create(:case, date: 10.days.ago)
        case_two = FactoryBot.create(:case, date: 15.days.ago)
        expect(Case.first.mom_cases_growth).to eq(200)
      end
    end

  end

  describe '#default_avatar_url' do
    it 'takes the avatar''s default URL and turns this into a column' do
      this_case = FactoryBot.create(:case)
      avatar_mock = double('Avatar', url: 'https://avatar.com')
      allow(this_case).to receive(:default_avatar_url).and_return(avatar_mock.url)
      expect(this_case.default_avatar_url).to_not be_nil
    end
  end

  describe 'scopes' do

    it 'returns cases based on case' do
      louisiana = FactoryBot.create(:state_louisiana)
      texas = FactoryBot.create(:state_texas)

      texas_case = FactoryBot.create(:case,
                                       city: 'Houston',
                                       state_id: texas.id)
      louisiana_case = FactoryBot.create(:case,
                                            city: 'Baton Rouge',
                                            state_id: louisiana.id)

      sorted_cases = Case.by_state texas.id
      expect(sorted_cases.count).to eq 1
      expect(sorted_cases.to_a).not_to include louisiana_case
    end

    it 'returns cases created in the past month' do
      dc = FactoryBot.create(:state_dc)
      louisiana = FactoryBot.create(:state_louisiana)
      texas = FactoryBot.create(:state_texas)

      texas_case = FactoryBot.create(:case,
                                       city: 'Houston',
                                       state_id: texas.id,
                                       created_at: Time.current)
      louisiana_case = FactoryBot.create(:case,
                                            city: 'Baton Rouge',
                                            state_id: louisiana.id,
                                            created_at: 5.weeks.ago)
      dc_case = FactoryBot.create(:case,
                                     city: 'Washington',
                                     state_id: dc.id,
                                     created_at: 1.year.ago)

      recent_case = Case.created_this_month
      expect(recent_case.count).to eq 1
      expect(recent_case.to_a).not_to include(louisiana_case)
      expect(recent_case.to_a).not_to include(dc_case)
    end

    it 'returns the most recently occurring cases' do
      dc = FactoryBot.create(:state_dc)
      louisiana = FactoryBot.create(:state_louisiana)
      texas = FactoryBot.create(:state_texas)

      texas_case = FactoryBot.create(:case,
                                        city: 'Houston',
                                        state_id: texas.id,
                                        date: Time.current)
      louisiana_case = FactoryBot.create(:case,
                                            city: 'Baton Rouge',
                                            state_id: louisiana.id,
                                            date: 2.weeks.ago)
      dc_case = FactoryBot.create(:case,
                                     city: 'Washington',
                                     state_id: dc.id,
                                     date: 1.year.ago)

      recent_cases = Case.most_recent_occurrences 1.month.ago
      expect(recent_cases.count).to eq 2
      expect(recent_cases.to_a).not_to include(dc_case)
    end

    it 'returns the most recently updated cases' do
      dc = FactoryBot.create(:state_dc)
      louisiana = FactoryBot.create(:state_louisiana)
      texas = FactoryBot.create(:state_texas)

      texas_case = FactoryBot.create(:case,
                                        city: 'Houston',
                                        state_id: texas.id,
                                        updated_at: Time.current)
      louisiana_case = FactoryBot.create(:case,
                                            city: 'Baton Rouge',
                                            state_id: louisiana.id,
                                            updated_at: 2.weeks.ago)
      dc_case = FactoryBot.create(:case,
                                     city: 'Washington',
                                     state_id: dc.id,
                                     updated_at: 1.year.ago)

      recent_cases = Case.recently_updated 1.month.ago
      expect(recent_cases.count).to eq 2
      expect(recent_cases.to_a).not_to include(dc_case)
    end

    it 'returns cases sorted by update date' do
      dc = FactoryBot.create(:state_dc)
      louisiana = FactoryBot.create(:state_louisiana)
      texas = FactoryBot.create(:state_texas)

      texas_case = FactoryBot.create(:case,
                                        city: 'Houston',
                                        state_id: texas.id,
                                        updated_at: Time.current)
      louisiana_case = FactoryBot.create(:case,
                                            city: 'Baton Rouge',
                                            state_id: louisiana.id,
                                            updated_at: 2.weeks.ago)
      dc_case = FactoryBot.create(:case,
                                     city: 'Washington',
                                     state_id: dc.id,
                                     updated_at: 1.year.ago)

      sorted_cases = Case.sorted_by_update 2
      expect(sorted_cases.count).to eq 2
      expect(sorted_cases.to_a).not_to include(dc_case)
    end

    it 'returns cases sorted by number of followers' do
      dc = FactoryBot.create(:state_dc)
      louisiana = FactoryBot.create(:state_louisiana)
      texas = FactoryBot.create(:state_texas)

      texas_case = FactoryBot.create(:case,
                                        city: 'Houston',
                                        state_id: texas.id,
                                        updated_at: Time.current)
      louisiana_case = FactoryBot.create(:case,
                                            city: 'Baton Rouge',
                                            state_id: louisiana.id,
                                            updated_at: 2.weeks.ago)
      dc_case = FactoryBot.create(:case,
                                     city: 'Washington',
                                     state_id: dc.id,
                                     updated_at: 1.year.ago)

      follow_one = FactoryBot.create(:follow, followable_id: texas_case.id)
      follow_two = FactoryBot.create(:follow, followable_id: texas_case.id)
      follow_three = FactoryBot.create(:follow, followable_id: dc_case.id)
      follow_four = FactoryBot.create(:follow, followable_id: dc_case.id)
      follow_five = FactoryBot.create(:follow, followable_id: louisiana_case.id)

      sorted_cases = Case.sorted_by_followers 2
      expect(sorted_cases.count).to eq 2
      expect(sorted_cases.to_a).not_to include(louisiana_case)
    end
  end
end
