# frozen_string_literal: true

require 'rails_helper'

describe SortAgenciesOrdinally do

  let(:agency_one) { FactoryBot.create(:agency, name: "Alan Anderson PD") }
  let(:agency_two) { FactoryBot.create(:agency, name: "Bob Barker PD") }
  let(:agency_three) { FactoryBot.create(:agency, name: '1st PD') }

  context 'when no agencies start with a number' do
    before do
      agency_one
      agency_two
    end

    it 'sorts the agencies correctly' do
      sorted_agencies = SortAgenciesOrdinally.call(Agency.all)
      expect(sorted_agencies).to eq([agency_one, agency_two])
    end
  end

  context 'when one agency starts with a number' do
    before do
      agency_one
      agency_two
      agency_three
    end

    it 'sorts the agencies correctly' do
      sorted_agencies = SortAgenciesOrdinally.call(Agency.all)
      expect(sorted_agencies).to eq([agency_three, agency_one, agency_two])
    end
  end

  context 'when agencies start with varying numbers' do
    before do
      agency_one
      agency_two
      agency_three
    end

    it 'sorts the agencies correctly' do
      agency_four = FactoryBot.create(:agency, name: '18th PD')

      sorted_agencies = SortAgenciesOrdinally.call(Agency.all)
      expect(sorted_agencies).to eq([agency_three,
                                     agency_four,
                                     agency_one,
                                     agency_two])
    end
  end

  context 'when two agencies start with the same number' do
    before do
      agency_one
      agency_two
      agency_three
    end

    it 'sorts the agencies correctly' do
      agency_four = FactoryBot.create(:agency, name: '1st Police Department')

      sorted_agencies = SortAgenciesOrdinally.call(Agency.all)
      expect(sorted_agencies).to eq([agency_three,
                                     agency_four,
                                     agency_one,
                                     agency_two])
    end
  end
end