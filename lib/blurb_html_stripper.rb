# frozen_string_literal: true

# One-off cleanup for legacy HTML stored in cases.blurb before save-time stripping.
module BlurbHtmlStripper
  TAG_PATTERN = /<[^>]+>/

  Affected = Struct.new(:record, :stripped, keyword_init: true)

  module_function

  def preview(text)
    snippet = text.to_s.gsub(/\s+/, ' ').strip
    snippet.length <= 80 ? snippet : "#{snippet[0, 77]}..."
  end

  def affected_cases
    Case.find_each.filter_map { |this_case| affected_entry(this_case) }
  end

  def affected_entry(this_case)
    blurb = this_case.blurb
    return if blurb.blank?
    return unless blurb.match?(TAG_PATTERN)

    Affected.new(
      record: this_case,
      stripped: ActionController::Base.helpers.strip_tags(blurb)
    )
  end

  def report(affected)
    lines = ["Cases with HTML in blurb: #{affected.size}"]
    affected.each do |entry|
      record = entry.record
      lines << "#{record.id} #{record.slug}"
      lines << "  before: #{preview(record.blurb)}"
      lines << "  after:  #{preview(entry.stripped)}"
    end
    lines.join("\n")
  end

  def apply!(affected)
    affected.each { |entry| persist_stripped_blurb(entry.record, entry.stripped) }
    count = affected.size
    noun = count == 1 ? 'case' : 'cases'
    "Updated #{count} #{noun}."
  end

  def persist_stripped_blurb(record, stripped_blurb)
    record.update_columns(blurb: stripped_blurb)
  end
end
