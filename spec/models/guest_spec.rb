# frozen_string_literal: true

require 'rails_helper'

describe Guest do
  context '#name' do
    it 'returns Guest' do
      guest = Guest.new
      expect(guest.name).to eq('Guest')
    end
  end
end
