# frozen_string_literal: true

# Given a relation containing all of the agency objects, sort them by name while accounting for ordinal
# numbers
class SortAgenciesOrdinally
  include Service

  def call(agencies)
    first_sort = agencies.sort_by { |e| ActiveSupport::Inflector.transliterate(e.name.downcase) }
    names_with_numbers = first_sort.select { |agency| agency.name.match(/(\d+)/) }
    return first_sort if names_with_numbers.empty?
    names_with_no_numbers = first_sort - names_with_numbers
    sorted_names_with_numbers = ordinal_sort(names_with_numbers)
    sorted_names_with_numbers + names_with_no_numbers
  end

  private

  # Performs ordinal sort removes number portion from string to sort
  # number portion properly, then returns array of agency objects based on sorted names
  def ordinal_sort(agencies)
    name_object_hash = {}
    agencies.each { |agency| name_object_hash[agency.name] = agency }

    names = name_object_hash.keys
    sorted_names = names.sort_by do |n|
      [n.split(/(\d+)/)[1].to_i, n.split(/\s/)[1]]
    end

    sorted_names.collect { |n| name_object_hash[n] }
  end
end