describe 'cases:add_blurb' do
  include_context 'rake'

  let(:cases) { create_list(:case, 5, :skip_validate, blurb: nil)}

  it 'adds a blurb to each case' do
    subject.invoke
    Case.all.each do |this_case|
      expect(this_case.blurb).not_to be_nil
    end
  end
end