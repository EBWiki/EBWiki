# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ReviewDbConnection do
  describe '.reset_pool!' do
    it 'clears caches and re-establishes the ActiveRecord connection' do
      handler = ActiveRecord::Base.connection_handler
      expect(handler).to receive(:clear_all_connections!)
      expect(ActiveRecord::Base).to receive(:establish_connection)

      described_class.reset_pool!
    end
  end
end
