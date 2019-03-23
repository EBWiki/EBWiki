# frozen_string_literal: true

# This module contains a number of methods to calculate various statistics
module Statistics
  def self.mom_changed_metric_growth(metric_at_start:, metric_at_end:)
    return 0 if metric_at_end.size.zero?

    metric_growth = metric_at_start.size - metric_at_end.size
    return (metric_at_end.size * 100) if metric_growth.zero?

    (((metric_at_end.size.to_f / metric_growth) - 1) * 100).round(2)
  end

  def self.mom_total_metric_growth(metric_at_start:, metric_at_end:)
    return 0 if metric_at_end.size.zero?

    metric_growth = metric_at_start.size - metric_at_end.size
    return (metric_at_end.size * 100) if metric_growth.zero?

    (metric_at_end.size.to_f / metric_growth * 100).round(2)
  end

  # rubocop:disable Metrics/AbcSize
  def self.mom_unique_followers_growth(metric_at_start:, metric_at_end:)
    return 0 if metric_at_end.size.zero?

    metric_at_start_count = FollowQuery.new(metric_at_start).distinct_count
    metric_at_end_count = FollowQuery.new(metric_at_end).distinct_count

    metric_growth = metric_at_start_count - metric_at_end_count
    return (metric_at_end_count * 100) if metric_growth.zero?

    (metric_at_end_count.to_f / metric_growth * 100).round(2)
  end
  # rubocop:enable Metrics/AbcSize
end
