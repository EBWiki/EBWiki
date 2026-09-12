# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ReviewDbConnection do
  describe '.reset_pool!' do
    it 'clears caches and re-establishes the ActiveRecord connection' do
      handler = ActiveRecord::Base.connection_handler
      allow(ActiveRecord::Base).to receive(:clear_query_caches_for_current_thread).and_call_original
      allow(ActiveRecord::Base).to receive(:establish_connection).and_call_original
      allow(handler).to receive(:clear_all_connections!).and_call_original
      expect(ActiveRecord::Base).to receive(:clear_query_caches_for_current_thread).at_least(:once)
      expect(handler).to receive(:clear_all_connections!).at_least(:once)
      expect(ActiveRecord::Base).to receive(:establish_connection).at_least(:once)

      described_class.reset_pool!
    end
  end

  describe '.cached_plan_error?' do
    it 'detects cached-plan errors from PG::FeatureNotSupported' do
      pg_error = PG::FeatureNotSupported.new('ERROR: cached plan must not change result type')
      ar_error = ActiveRecord::StatementInvalid.new('wrapper')
      allow(ar_error).to receive(:cause).and_return(pg_error)

      expect(described_class.cached_plan_error?(ar_error)).to be(true)
    end
  end

  describe '.with_pooler_retry' do
    it 'reconnects and retries once after a cached-plan error' do
      attempts = 0
      allow(described_class).to receive(:reset_pool!)

      described_class.with_pooler_retry do
        attempts += 1
        next unless attempts == 1

        pg_error = PG::FeatureNotSupported.new('ERROR: cached plan must not change result type')
        ar_error = ActiveRecord::StatementInvalid.new('wrapper')
        allow(ar_error).to receive(:cause).and_return(pg_error)
        raise ar_error
      end

      expect(attempts).to eq(2)
      expect(described_class).to have_received(:reset_pool!).once
    end
  end
end
