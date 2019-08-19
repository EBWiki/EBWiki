# frozen_string_literal: true

desc 'Add slug to cases'
task add_slug: :environment do
  p 'Task started!'
  cases = Case.where(title: nil)
  cases.each do |this_case|
    next unless this_case.subjects.count.positive?

    this_case.update_attributes(
      title: this_case.subjects.first.name,
      slug: this_case.subjects.first.name.parameterize
    )
    this_case.save
    p "fixed this_case number #{this_case.id}"
  end
  p 'Done!'
end
