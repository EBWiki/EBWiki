# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Subject, type: :model do
  describe 'Validations' do
    it { should validate_presence_of(:name).with_message('Name of the victim can\'t be blank.') }
  end
end
