require 'rails_helper'

RSpec.describe AgenciesHelper, type: :helper do

  before(:each) do
    @texas = FactoryBot.create(:state_texas)
  end

  let(:agency) { FactoryBot.create(:agency, name: 'Spec_Agency', state_id: @texas.id) }

  describe '#link_to_name' do
    it 'displays formatted agency name' do
      expect(helper.link_to_name(agency)).to include('Spec_Agency')
    end
  end

  describe '#link_to_edit' do
    it 'displays formatted edit link' do
      expect(helper.link_to_edit(agency)).to include('/agencies/spec_agency/edit')
    end
  end
end
