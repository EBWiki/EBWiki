# frozen_string_literal: true

describe 'cases:strip_blurb_html' do
  include_context 'rake'

  let(:task_path) { 'lib/tasks/blurbs' }

  let!(:plain_case) { create(:case, blurb: 'Plain text summary with no markup.') }
  let!(:html_case) do
    create(:case, blurb: '<b>Bold</b> lead for the case page.')
  end

  around do |example|
    previous_apply = ENV.fetch('APPLY', nil)
    ENV.delete('APPLY')
    example.run
  ensure
    if previous_apply.nil?
      ENV.delete('APPLY')
    else
      ENV['APPLY'] = previous_apply
    end
  end

  it 'does not change blurbs and reports affected case ids on dry run' do
    expect do
      expect { subject.invoke }.to output(/id=#{html_case.id}/).to_stdout
    end.not_to(change { html_case.reload.blurb })

    expect(plain_case.reload.blurb).to eq('Plain text summary with no markup.')
  end

  context 'when APPLY=1' do
    before { ENV['APPLY'] = '1' }

    it 'strips HTML from blurbs and leaves plain-text blurbs unchanged' do
      subject.invoke

      expect(html_case.reload.blurb).to eq('Bold lead for the case page.')
      expect(plain_case.reload.blurb).to eq('Plain text summary with no markup.')
    end

    it 'is a no-op on a second run' do
      subject.invoke
      html_case.reload

      subject.reenable
      expect do
        subject.invoke
      end.not_to(change { html_case.reload.blurb })
    end
  end
end
