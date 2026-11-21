# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MpvPhotoImport::Importer do
  let(:csv_path) { Rails.root.join('spec/fixtures/files/mpv_import_sample.csv') }
  let(:california) { create(:state, name: 'California', ansi_code: 'CA') }
  let(:texas) { create(:state, name: 'Texas', ansi_code: 'TX') }
  let(:ohio) { create(:state, name: 'Ohio', ansi_code: 'OH') }
  let(:new_york) { create(:state, name: 'New York', ansi_code: 'NY') }
  let(:louisiana) { create(:state, name: 'Louisiana', ansi_code: 'LA') }

  before do
    allow_any_instance_of(Case).to receive(:geocode).and_return(true)

    create(:case, title: 'Maria Lopez', date: Date.new(2020, 5, 15), state: california)
    create(:case, title: 'John Smith', date: Date.new(2020, 6, 1), state: texas)
    create(:case, title: 'Alice Exact', date: Date.new(2020, 8, 10), state: ohio)
    create(:case, title: 'Eve Second Exact', date: Date.new(2020, 12, 1), state: louisiana)
    create(:case, title: 'Kelly Exact', date: Date.new(2021, 3, 10), state: create(:state, name: 'Florida', ansi_code: 'FL'))
    create(:case, title: 'Nina Auto Two', date: Date.new(2021, 6, 18), state: california)
    create(:case, title: 'Paula Review Date', date: Date.new(2021, 8, 23), state: new_york)
  end

  it 'imports the fixture with auto matches, review rows, and mugshot rejections' do
    report = described_class.new(csv_path: csv_path).call

    maria = Case.find_by(title: 'Maria Lopez')
    expect(maria.photo_url).to eq('https://example.com/photos/maria-lopez.jpg')
    expect(maria.photo_status).to eq('shown')
    expect(maria.photo_credit).to eq('Mapping Police Violence')

    expect(CaseMpvPhotoReview.find_by(mpv_name: 'Jon Smith')).to be_present

    expect(report.auto_matched).to be >= 3
    expect(report.review_queue).to be >= 1
    expect(report.rejected).to be >= 2
    expect(report.to_h).to include(:skipped, :error_count)
  end

  it 'does not auto-accept when only the name is slightly off' do
    described_class.new(csv_path: csv_path).call

    john_case = Case.find_by(title: 'John Smith')
    expect(john_case.photo_url).to be_nil
  end
end
