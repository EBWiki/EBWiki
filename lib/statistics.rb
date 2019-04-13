# frozen_string_literal: true

# This module contains a number of methods to calculate various statistics
module Statistics
  # rubocop:disable Metrics/LineLength
  def self.mom_metric_growth(metric_at_start:, metric_at_end:)
    return metric_at_end.size * 100 if metric_at_start.size.zero?

    (((metric_at_end.size - metric_at_start.size) / metric_at_start.size) * 100).round(2)
  end

  # rubocop:disable Metrics/AbcSize
  def self.mom_unique_followers_growth(metric_at_start:, metric_at_end:)
    return 0 if metric_at_start.size.zero?

    metric_at_start_count = FollowQuery.new(metric_at_start).distinct_count
    metric_at_end_count = FollowQuery.new(metric_at_end).distinct_count

    (((metric_at_end_count - metric_at_start_count) / metric_at_start_count) * 100).round(2)
  end
  # rubocop:enable Metrics/AbcSize
  # rubocop:enable Metrics/LineLength
end
