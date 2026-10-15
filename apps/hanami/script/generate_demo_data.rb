# frozen_string_literal: true

require 'json'
require 'fileutils'

ROOT = File.expand_path('..', __dir__)
DIM = 32
PLACEHOLDER_DIR = File.join(ROOT, 'public', 'placeholders')

def embedding_for(id)
  Array.new(DIM) { |i| i.even? ? (((id * 3) + i) % 50) / 1000.0 : (((id * 7) + i) % 50) / 1000.0 }
end

CASES = [
  ['riverside-demo-a', 'Demo case Alpha', 'Riverside', 'CA', 2019, 'Riverside PD',
   %w[traffic stop preview]],
  ['oakland-demo-b', 'Demo case Bravo', 'Oakland', 'CA', 2020, 'Oakland PD', %w[downtown preview]],
  ['sacramento-demo-c', 'Demo case Charlie', 'Sacramento', 'CA', 2018, 'Sacramento SO',
   %w[capitol preview]],
  ['fresno-demo-d', 'Demo case Delta', 'Fresno', 'CA', 2021, 'Fresno PD', %w[central preview]],
  ['san-jose-demo-e', 'Demo case Echo', 'San Jose', 'CA', 2017, 'San Jose PD', %w[silicon preview]],
  ['bakersfield-demo-f', 'Demo case Foxtrot', 'Bakersfield', 'CA', 2022, 'Kern SO',
   %w[valley preview]],
  ['stockton-demo-g', 'Demo case Golf', 'Stockton', 'CA', 2016, 'Stockton PD', %w[port preview]],
  ['modesto-demo-h', 'Demo case Hotel', 'Modesto', 'CA', 2023, 'Modesto PD', %w[grid preview]],
  ['chico-demo-i', 'Demo case India', 'Chico', 'CA', 2015, 'Chico PD', %w[campus preview]],
  ['redding-demo-j', 'Demo case Juliet', 'Redding', 'CA', 2014, 'Redding PD', %w[north preview]],
  ['santa-rosa-demo-k', 'Demo case Kilo', 'Santa Rosa', 'CA', 2024, 'Santa Rosa PD',
   %w[wine preview]],
  ['monterey-demo-l', 'Demo case Lima', 'Monterey', 'CA', 2013, 'Monterey PD', %w[coast preview]]
].freeze

COLORS = %w[#264653 #2a9d8f #e9c46a #f4a261 #e76f51 #606c38 #283618 #023047 #219ebc #8ecae6].freeze

FileUtils.mkdir_p(PLACEHOLDER_DIR)

cases = CASES.each_with_index.map do |(slug, title, city, state, year, agency, tags), idx|
  id = idx + 1
  color = COLORS[id % COLORS.size]
  accent = COLORS[(id + 3) % COLORS.size]
  svg_name = "demo-#{id}.svg"
  svg_path = File.join(PLACEHOLDER_DIR, svg_name)
  File.write(
    svg_path,
    <<~SVG
      <svg xmlns="http://www.w3.org/2000/svg" width="320" height="320" viewBox="0 0 320 320" role="img" aria-label="Placeholder tile #{id}">
        <rect width="320" height="320" fill="#{color}"/>
        <rect x="24" y="24" width="272" height="272" fill="#{accent}" opacity="0.35"/>
        <text x="160" y="150" text-anchor="middle" font-family="sans-serif" font-size="22" fill="#ffffff">PLACEHOLDER</text>
        <text x="160" y="185" text-anchor="middle" font-family="sans-serif" font-size="16" fill="#ffffff">Demo #{id}</text>
      </svg>
    SVG
  )

  {
    'id' => id,
    'slug' => slug,
    'title' => title,
    'city' => city,
    'state' => state,
    'year' => year,
    'agency' => agency,
    'tags' => tags,
    'image_path' => "/placeholders/#{svg_name}",
    'embedding' => embedding_for(id),
    'attribution' => 'Synthetic preview tile (not a real case photo).'
  }
end

File.write(File.join(ROOT, 'data', 'demo_cases.json'), JSON.pretty_generate(cases))
puts "Wrote #{cases.size} demo cases and SVG placeholders."
