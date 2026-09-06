# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ReviewSessionsTable do
  describe '.ensure!' do
    let(:connection) { instance_double(ActiveRecord::ConnectionAdapters::PostgreSQLAdapter) }

    before do
      allow(ActiveRecord::Base).to receive(:connection).and_return(connection)
      allow(connection).to receive(:table_exists?).with(:sessions).and_return(false)
      allow(connection).to receive(:create_table).with(:sessions)
      allow(connection).to receive(:index_exists?).with(:sessions, :session_id).and_return(false)
      allow(connection).to receive(:index_exists?).with(:sessions, :updated_at).and_return(false)
      allow(connection).to receive(:add_index)
    end

    it 'creates the sessions table and indexes when missing' do
      described_class.ensure!

      expect(connection).to have_received(:create_table).with(:sessions)
      expect(connection).to have_received(:add_index).with(:sessions, :session_id, unique: true)
      expect(connection).to have_received(:add_index).with(:sessions, :updated_at)
    end

    it 'skips table creation when sessions already exists' do
      allow(connection).to receive(:table_exists?).with(:sessions).and_return(true)

      described_class.ensure!

      expect(connection).not_to have_received(:create_table)
      expect(connection).to have_received(:add_index).with(:sessions, :session_id, unique: true)
      expect(connection).to have_received(:add_index).with(:sessions, :updated_at)
    end
  end
end
