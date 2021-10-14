# frozen_string_literal: true

# Value object - rollout
class Rollout < ValueObject
  attr_reader :name, :description, :creator, :date_added

  def initialize(path_to_yaml) # rubocop:disable Lint/MissingSuper
    file = YAML.load_file(path_to_yaml)
    @name = file['name']
    @description = file['description']
    @creator = file['creator']
    @date_added = file['date_added']
  end

  def to_s
    name.to_s
  end
end
