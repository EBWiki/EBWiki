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
      raw = JSON.parse(File.read(data_path))
      raw.map do |row|
        DemoCase.new(
          id: row['id'],
          slug: row['slug'],
          title: row['title'],
          city: row['city'],
          state: row['state'],
          year: row['year'],
          agency: row['agency'],
          tags: row['tags'],
          image_path: row['image_path'],
          embedding: row['embedding'],
          attribution: row['attribution']
        )
      end
    end

    def text_match(cases, query)
      q = query.to_s.downcase.strip
      return cases if q.empty?

      cases.select do |c|
        [c.title, c.city, c.state, c.agency, c.year.to_s, *c.tags].join(' ').downcase.include?(q)
      end
    end
  end
end
