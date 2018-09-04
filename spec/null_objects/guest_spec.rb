# frozen_string_literal: true

require './app/null_objects/guest'

require 'rails_helper'

describe NullObjects::Guest do
  context '#name' do
    it 'returns Guest' do
      guest = NullObjects::Guest.new
      expect(guest.name).to eq('Guest')
    end
  end
end
