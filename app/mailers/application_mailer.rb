# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  default from: 'EndBiasWiki@gmail.com'
  layout 'mailer'
end
