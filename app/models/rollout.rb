# frozen_string_literal: true

# Value object - rollout
class Rollout
  attr_reader :name, :description, :creator, :date_added

  def initialize(path_to_yaml)
    file = YAML.load_file(path_to_yaml)
    @name = file['name']
    @description = file['description']
    @creator = file['creator']
    @date_added = file['date_added']
  end

  def to_s
    "name #{name}"
  end

  def ==(other)
    self.class == other.class && self.to_s == other.to_s
  end
end
