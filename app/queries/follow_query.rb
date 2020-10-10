# frozen_string_literal: true

# Query objects for follows
class FollowQuery
  def initialize(scope = Follow.all)
    @scope = scope
  end

  def distinct_count
    @scope.count('DISTINCT follower_id')
  end
end
