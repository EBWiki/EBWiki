# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MpvPhotoImport::NameNormalizer do
  describe '.normalize' do
    it 'lowercases, strips punctuation, and removes generational suffixes' do
      expect(described_class.normalize('Maria Lopez')).to eq('maria lopez')
      expect(described_class.normalize('Kelly Exact Jr.')).to eq('kelly exact')
      expect(described_class.normalize('  John   Paul  ')).to eq('john paul')
    end

    it 'returns an empty string for blank input' do
      expect(described_class.normalize(nil)).to eq('')
      expect(described_class.normalize('   ')).to eq('')
    end
  end
end
