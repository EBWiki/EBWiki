# frozen_string_literal: true

describe 'staging:sample_content' do
  let(:rake) { Rake::Application.new }

  around do |example|
    previous_rake = Rake.application
    Rake.application = rake
    example.run
  ensure
    Rake.application = previous_rake
  end

  before do
    load Rails.root.join('lib/tasks/staging_sample_content.rake')
    Rake::Task.define_task(:environment)
  end

  it 'aborts outside staging (fail closed)' do
    allow(Rails.env).to receive(:staging?).and_return(false)

    expect { rake['staging:sample_content'].invoke }.to raise_error(SystemExit, /RAILS_ENV=staging/)
  end

  it 'aborts on staging without the typed confirmation' do
    allow(Rails.env).to receive(:staging?).and_return(true)
    allow(ENV).to receive(:[]).and_call_original
    allow(ENV).to receive(:[]).with('CONFIRM_STAGING_SAMPLE_CONTENT').and_return(nil)

    expect { rake['staging:sample_content'].invoke }
      .to raise_error(SystemExit, /CONFIRM_STAGING_SAMPLE_CONTENT=add-sample-cases/)
  end
end
