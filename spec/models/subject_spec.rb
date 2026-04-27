# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Subject, type: :model do
  describe 'Validations' do
    it { should validate_presence_of(:name).with_message('Name of the victim can\'t be blank.') }

    it 'is valid without gender or ethnicity' do
      expect(build(:subject, gender: nil, ethnicity: nil)).to be_valid
    end

    it 'is valid with gender and ethnicity' do
      expect(build(:subject, :with_gender, :with_ethnicity)).to be_valid
    end
  end
end
