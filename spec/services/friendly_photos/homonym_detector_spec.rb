# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FriendlyPhotos::HomonymDetector do
  it 'flags Sir Walter Scott style historical hits' do
    result = described_class.call(
      text: 'Portrait of Sir Walter Scott, novelist, 19th century',
      case_year: 2015
    )

    expect(result.likely_homonym).to be true
    expect(result.score_penalty).to eq(-25)
  end

  it 'passes modern case-relevant portraits' do
    result = described_class.call(
      text: 'Family portrait memorial photo',
      case_year: 2015
    )

    expect(result.likely_homonym).to be false
  end
end
