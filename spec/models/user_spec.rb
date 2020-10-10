# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User do
  it_behaves_like 'a sanatized_record'

  describe 'Validations' do
    it { should validate_presence_of(:name).with_message('Please add a name.') }
    subject { FactoryBot.create(:user) }
    it { should validate_uniqueness_of(:email).case_insensitive }
  end
end
