# frozen_string_literal: true

describe 'cases:strip_blurb_html' do
  include_context 'rake'

  let(:task_path) { 'lib/tasks/blurbs' }

  let!(:plain_case) do
    create(:case, blurb: 'Plain text blurb with no tags.')
  end

  let!(:html_case) do
    record = create(:case, blurb: 'Placeholder')
    record.update_columns(blurb: '<p>Hello <b>world</b></p>')
    record
  end

  let!(:second_html_case) do
    record = create(:case, blurb: 'Placeholder')
    record.update_columns(blurb: '<script>x</script>Summary')
    record
  end

  def invoke_task
    capture_stdout { subject.invoke }
  end

  def capture_stdout
    previous_stdout = $stdout
    $stdout = StringIO.new
    yield
    $stdout.string
  ensure
    $stdout = previous_stdout
  end

  context 'when APPLY is not set' do
    it 'does not change blurbs and reports affected case ids' do
      output = invoke_task

      expect(plain_case.reload.blurb).to eq('Plain text blurb with no tags.')
      expect(html_case.reload.blurb).to eq('<p>Hello <b>world</b></p>')
      expect(second_html_case.reload.blurb).to eq('<script>x</script>Summary')

      expect(output).to include('Cases with HTML in blurb: 2')
      expect(output).to include(html_case.id.to_s)
      expect(output).to include(html_case.slug)
      expect(output).to include(second_html_case.id.to_s)
      expect(output).to include(second_html_case.slug)
      expect(output).to include('Dry run only')
    end
  end

  context 'when APPLY=1' do
    around do |example|
      previous = ENV.fetch('APPLY', nil)
      ENV['APPLY'] = '1'
      example.run
    ensure
      if previous.nil?
        ENV.delete('APPLY')
      else
        ENV['APPLY'] = previous
      end
    end

    it 'strips HTML from affected blurbs and leaves plain blurbs unchanged' do
      invoke_task

      expect(plain_case.reload.blurb).to eq('Plain text blurb with no tags.')
      expect(html_case.reload.blurb).to eq('Hello world')
      expect(second_html_case.reload.blurb).to eq('xSummary')
    end

    it 'does nothing on a second run' do
      invoke_task
      html_case.reload
      second_html_case.reload

      expect do
        invoke_task
      end.not_to(change { [html_case.reload.blurb, second_html_case.reload.blurb] })
    end
  end
end
