# frozen_string_literal: true

# This module contains a number of methods to calculate various statistics
module Statistics
  def self.metric_growth(start_metric:, end_metric:)
    return end_metric.size * 100 if start_metric.size.zero?

    (((end_metric.size - start_metric.size) / start_metric.size) * 100).round(2)
  end

  def self.unique_followers_growth(start_metric:, end_metric:)
    return 0 if start_metric.size.zero?

    start_metric_count = FollowQuery.new(start_metric).distinct_count
    end_metric_count = FollowQuery.new(end_metric).distinct_count

    (((end_metric_count - start_metric_count) / start_metric_count) * 100).round(2)
  end
end
