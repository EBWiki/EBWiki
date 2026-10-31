# frozen_string_literal: true

describe 'staging:sample_content' do
  let(:rake) { Rake::Application.new }

  before do
    Rake.application = rake
    Rake.application.rake_require(
      'staging_sample_content',
      [Rails.root.join('lib/tasks').to_s]
    )
    Rake::Task.define_task(:environment)
  end

  it 'aborts outside staging (fail closed)' do
    allow(Rails.env).to receive(:staging?).and_return(false)

    expect { rake['staging:sample_content'].invoke }.to raise_error(SystemExit, /RAILS_ENV=staging/)
  end
end
