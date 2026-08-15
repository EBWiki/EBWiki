# frozen_string_literal: true

require 'rails_helper'

describe 'photos:search_friendly' do
  include_context 'rake'

  it 'runs the batch search and prints results' do
    allow(FriendlyPhotos::BatchSearch).to receive(:call).and_return([])

    expect { subject.invoke }.to output('').to_stdout
    expect(FriendlyPhotos::BatchSearch).to have_received(:call)
  end
end

describe 'photos:classify_current' do
  include_context 'rake'

  it 'classifies current avatars' do
    allow(FriendlyPhotos::CurrentAvatarClassifier).to receive(:call).and_return(2)

    expect { subject.invoke }.to output(/Marked 2 current avatars as mugshots/).to_stdout
    expect(FriendlyPhotos::CurrentAvatarClassifier).to have_received(:call)
  end
end
