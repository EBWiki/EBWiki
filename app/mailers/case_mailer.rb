# frozen_string_literal: true

# Class responsible for sending emails about cases
class CaseMailer < ApplicationMailer
  default from: 'EndBiasWiki@gmail.com'

  def send_followers_email(users:, this_case:)
    @this_case = this_case
    users.each do |user|
      # rubocop:disable Metrics/LineLength
      Rails.logger.info("CaseMailer#send_followers_email: Sending notification to #{user.email} about case #{this_case.title}")
      # rubocop:enable Metrics/LineLength

      mail(to: user.email, subject: "The #{@this_case.title} case has been updated on EBWiki.")
    end
  end

  def send_deletion_email(users:, this_case:)
    @this_case = this_case
    users.each do |user|
      # rubocop:disable Metrics/LineLength

      Rails.logger.info("CaseMailer#send_deletion_email: Sending notification to #{user.email} about case #{this_case.title}")
      # rubocop:enable Metrics/LineLength
      mail(to: user.email, subject: "The #{@this_case.title} case has been removed from EBWiki")
    end
  end
end
