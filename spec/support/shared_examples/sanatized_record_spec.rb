# require 'rails_helper'
# frozen_string_literal: true

shared_examples 'a sanatized_record' do
  subject { build(target_class) }

  describe 'stripped_attributes' do
    described_class::STRIPPED_ATTRIBUTES.each do |attr|
      it "strips whitespaces from #{attr}" do
        original = subject[attr]
        subject[attr] = " #{original} "
        subject.validate
        expect(subject[attr]).to eq original
      end
    end
  end

  # DEPRECATION WARNING: Looking up factories by class is deprecated and will be removed in 5.0
  def target_class
    described_class.to_s.downcase.to_sym
  end
end
