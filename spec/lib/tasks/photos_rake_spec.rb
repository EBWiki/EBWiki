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

  it 'dry-runs by default and prints counts' do
    allow(FriendlyPhotos::CurrentAvatarClassifier).to receive(:call)
      .with(dry_run: true)
      .and_return(would_mark_mugshot: 2, unchanged: 5)

    expect do
      subject.invoke
    end.to output(/Dry run \(no database writes\).*Would mark as mugshot \(needs healthier photo\): 2/m).to_stdout
    expect(FriendlyPhotos::CurrentAvatarClassifier).to have_received(:call).with(dry_run: true)
  end

  it 'classifies current avatars when APPLY=1' do
    allow(FriendlyPhotos::CurrentAvatarClassifier).to receive(:call).with(no_args).and_return(2)

    previous = ENV.fetch('APPLY', nil)
    ENV['APPLY'] = '1'
    expect do
      subject.invoke
    end.to output(/Marked 2 current photos as needing a healthier photo/).to_stdout
    expect(FriendlyPhotos::CurrentAvatarClassifier).to have_received(:call)
  ensure
    ENV['APPLY'] = previous
  end
end
