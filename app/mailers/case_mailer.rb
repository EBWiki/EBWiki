# frozen_string_literal: true

# Class responsible for sending emails about cases
class CaseMailer < ApplicationMailer
  default from: 'EndBiasWiki@gmail.com'

  def send_followers_email(users:, this_case:)
    @this_case = this_case
    users.each do |user|
      log_info(user)
      mail(to: user.email, subject: "The #{@this_case.title} case has been updated on EBWiki.")
    end
  end

  def send_deletion_email(users:, this_case:)
    @this_case = this_case
    users.each do |user|
      log_info(user)
      mail(to: user.email, subject: "The #{@this_case.title} case has been removed from EBWiki")
    end
  end

  private

  def log_info(user)
    # rubocop:disable Layout/LineLength
    Rails.logger.info("CaseMailer#send_followers_email: Sending notification to #{user.email} about case #{@this_case.title}")
    # rubocop:enable Layout/LineLength
  end
end
