# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Search', type: :request do
  let(:texas) { FactoryBot.create(:state_texas) }
  let(:louisiana) { FactoryBot.create(:state_louisiana) }
  let(:subject_record) { FactoryBot.build(:subject) }

  let!(:houston_case) do
    FactoryBot.create(
      :case,
      title: 'Police shooting in Houston',
      blurb: 'Officer-involved shooting downtown',
      city: 'Houston',
      state: texas,
      date: 1.week.ago,
      summary: 'initial entry',
      subjects: [subject_record]
    )
  end
  let!(:baton_rouge_case) do
    FactoryBot.create(
      :case,
      title: 'Vehicular incident in Baton Rouge',
      blurb: 'Traffic stop escalation',
      city: 'Baton Rouge',
      state: louisiana,
      date: 1.day.ago,
      summary: 'initial entry',
      subjects: [FactoryBot.build(:subject)]
    )
  end

  describe 'GET /search' do
    it 'returns 200 and lists cases matching the query' do
      get '/search', params: { query: 'shooting' }

      expect(response).to have_http_status(:ok)
      expect(response.body).to include(houston_case.title)
      expect(response.body).not_to include(baton_rouge_case.title)
    end

    it 'filters results by state_id' do
      get '/search', params: { state_id: louisiana.id }

      expect(response).to have_http_status(:ok)
      expect(response.body).to include(baton_rouge_case.title)
      expect(response.body).not_to include(houston_case.title)
    end

    it 'paginates with the page parameter' do
      13.times do |index|
        FactoryBot.create(
          :case,
          title: "Pagination filler case #{index}",
          city: 'Houston',
          state: texas,
          date: index.days.ago,
          summary: 'filler',
          subjects: [FactoryBot.build(:subject)]
        )
      end

      get '/search', params: { page: 2 }

      expect(response).to have_http_status(:ok)
      expect(response.body).to include('Pagination filler case')
    end
  end
end
