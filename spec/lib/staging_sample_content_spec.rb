# frozen_string_literal: true

require 'rails_helper'
require Rails.root.join('lib/staging_sample_content')

RSpec.describe StagingSampleContent do
  describe '.ensure!' do
    it 'does nothing outside staging' do
      expect(Case).not_to receive(:find_or_initialize_by)
      described_class.ensure!
    end

    context 'when Rails.env is staging' do
      before do
        allow(Rails.env).to receive(:staging?).and_return(true)
        allow_any_instance_of(Case).to receive(:geocode)
      end

      it 'creates sample cases once and is idempotent on repeat' do
        expect { described_class.ensure! }.to change(Case, :count).by(StagingSampleContent::SAMPLES.size)
        expect { described_class.ensure! }.not_to change(Case, :count)
      end
    end
  end

  describe 'staging:sample_content rake task' do
    before do
      Rails.application.load_tasks
      Rake::Task['staging:sample_content'].reenable
    end

    it 'aborts outside the staging environment' do
      expect { Rake::Task['staging:sample_content'].invoke }.to raise_error(SystemExit)
    end
  end
end
