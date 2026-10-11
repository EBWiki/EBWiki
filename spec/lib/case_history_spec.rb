# frozen_string_literal: true

require 'rails_helper'
require 'case_history'

RSpec.describe CaseHistory, versioning: true do
  describe '.versions_for' do
    it 'returns versions newest-first' do
      this_case = FactoryBot.create(:case)
      this_case.update!(title: 'First change', summary: 'first summary')
      this_case.update!(title: 'Second change', summary: 'second summary')

      versions = described_class.versions_for(this_case)

      expect(versions.map(&:comment)).to eq(
        this_case.versions.order(created_at: :desc).pluck(:comment)
      )
    end

    it 'removes duplicate version rows that share the same visible event' do
      this_case = FactoryBot.create(:case)
      this_case.update!(overview: 'Updated overview', summary: 'Duplicate edit summary')
      source = this_case.versions.where(event: 'update').last

      PaperTrail::Version.create!(
        item_type: 'Case',
        item_id: this_case.id,
        event: source.event,
        whodunnit: source.whodunnit,
        comment: source.comment,
        created_at: source.created_at,
        object: source.object,
        object_changes: source.object_changes
      )

      versions = described_class.versions_for(this_case.reload)
      matching = versions.select { |version| version.comment == 'Duplicate edit summary' }

      expect(matching.size).to eq(1)
      expect(this_case.versions.where(comment: 'Duplicate edit summary').count).to eq(2)
    end
  end
end
