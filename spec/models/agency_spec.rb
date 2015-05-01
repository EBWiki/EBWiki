require 'rails_helper'

RSpec.describe Agency, type: :model do
  describe Agency do
	it { should have_many(:articles) }
  end
end
