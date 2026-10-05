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
