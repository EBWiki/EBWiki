# frozen_string_literal: true

require 'json'
require_relative 'vector_search'

class DemoCatalog
  VECTOR_DIM = 32

  DemoCase = Data.define(
    :id, :slug, :title, :city, :state, :year, :agency, :tags,
    :image_path, :embedding, :attribution
  )

  class << self
    def load(root:)
      data_path = File.join(root, 'data', 'demo_cases.json')
      JSON.parse(File.read(data_path)).map { |row| case_from_row(row) }
    end

    def text_match(cases, query)
      q = query.to_s.downcase.strip
      return cases if q.empty?

      cases.select do |c|
        [c.title, c.city, c.state, c.agency, c.year.to_s, *c.tags].join(' ').downcase.include?(q)
      end
    end

    def case_from_row(row)
      DemoCase.new(**row.transform_keys(&:to_sym))
    end

    private :case_from_row
  end
end
