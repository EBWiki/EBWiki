# frozen_string_literal: true

describe 'cases:add_blurb' do
  include_context 'rake'

  let(:cases) { create_list(:case, 5, :skip_validate, blurb: nil) }

  it 'adds a blurb to each case' do
    subject.invoke
    Case.all.each do |this_case|
      expect(this_case.blurb).not_to be_nil
    end
  end
end

describe 'cases:convert_cause_of_death' do
  include_context 'rake'

  let(:_case) { create(:case) }
  let(:cod) {  CauseOfDeath.create(name: 'Shooting') }

  xit 'converts cause of death from reference to enum' do
    _case.update_attribute :cause_of_death_id, cod.id
    subject.invoke
    _case.reload
    name = cod.name.downcase.parameterize(separator: '_')
    expect(_case.cause_of_death_name).to eq name
  end
end
