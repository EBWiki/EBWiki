# frozen_string_literal: true

require 'rails_helper'
require Rails.root.join('lib/staging_sample_content')

RSpec.describe StagingSampleContent do
  describe '.ensure!' do
    it 'does nothing outside staging' do
      expect(Case).not_to receive(:find_or_initialize_by)
      described_class.ensure!
    end
  end
end
