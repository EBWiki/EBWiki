# frozen_string_literal: true

require 'rails_helper'
require 'puma'

RSpec.describe 'Puma dependency' do
  it 'loads a patched Puma release' do
    expect(Gem.loaded_specs.fetch('puma').version).to be >= Gem::Version.new('7.2.1')
    expect(Puma::Const::PUMA_VERSION).to eq '7.2.1'
  end
end
