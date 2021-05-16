# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AttributeSanitizer do
  describe '#sanitize' do
    context 'for leading and trailing whitespace' do
      let(:sample) { build(:subject, name: " bob ") }

      it "strips those whitespaces" do
        sample.validate
        expect(sample.name).to eq 'bob'
      end    
    end

    context 'for trailing commas' do
      let(:sample) { build(:comment, content: 'A comment,') }

      it "strips those commas" do
        sample.validate
        expect(sample.content).to eq 'A comment'
      end
    end
  end
end