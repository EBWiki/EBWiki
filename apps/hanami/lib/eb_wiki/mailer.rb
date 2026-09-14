# frozen_string_literal: true

require "base64"
require "cgi"
require "net/smtp"

module EbWiki
  # Builds the same confirmation, reset, and follower emails Rails sends.
  # Hanami is the writer for events it handles. Rails still sends for Rails
  # writes until cutover — do not enable this against a shared production DB
  # while Rails is also delivering follower mail for the same update.
  #
  # SMTP is off unless HANAMI_SEND_MAIL=1 and SMTP_* (or SendGrid) is set.
  # That keeps the 2020 staging dump from emailing real people.
  class Mailer
    FROM_ADDRESS = "EndBiasWiki@gmail.com"
    FROM_NAME = "EndBiasWiki"
    HOME_URL = "http://ebwiki.org"

    Message = Struct.new(:to, :from, :subject, :html, keyword_init: true)

    class << self
      def deliveries
        @deliveries ||= []
      end

      def reset_deliveries!
        @deliveries = []
      end

      def confirmation_instructions(user:, token:, base_url:)
        name = escape(attr(user, :name))
        url = "#{normalize_base(base_url)}/users/confirmation?confirmation_token=#{CGI.escape(token.to_s)}"
        deliver(
          to: attr(user, :email),
          subject: "Confirmation instructions",
          html: <<~HTML
            <p>Welcome #{name}!</p>
            <p>Thanks for signing up for EBWiki.</p>
            <p><a href="#{escape(url)}">Click here to confirm your account</a></p>
          HTML
        )
      end

      def reset_password_instructions(user:, token:, base_url:)
        email = attr(user, :email)
        url = "#{normalize_base(base_url)}/password/edit?reset_password_token=#{CGI.escape(token.to_s)}"
        deliver(
          to: email,
          subject: "Reset password instructions",
          html: <<~HTML
            <p>Hello #{escape(email)}!</p>
            <p>Someone has requested a link to change your password. You can do this through the link below.</p>
            <p><a href="#{escape(url)}">Change my password</a></p>
            <p>If you didn't request this, please ignore this email.</p>
            <p>Your password won't change until you access the link above and create a new one.</p>
          HTML
        )
      end

      def send_followers_email(users:, this_case:, editor_name:, comment:, base_url:)
        title = attr(this_case, :title).to_s
        slug = attr(this_case, :slug).to_s
        case_url = "#{normalize_base(base_url)}/cases/#{CGI.escape(slug)}"
        editor = escape(editor_name.to_s)
        note = escape(comment.to_s)

        Array(users).filter_map do |user|
          to = attr(user, :email).to_s.strip
          next if to.empty?

          deliver(
            to: to,
            subject: "The #{title} case has been updated on EBWiki.",
            html: <<~HTML
              <h1> **ALERT** #{escape(title)} update:</h1>
              <p>Case editor #{editor}
              has updated the <a href="#{escape(case_url)}">#{escape(title)}</a> case on EBWiki today. To describe the update,
               #{editor} says: "#{note}".
              <p>
              <p> Please feel free to add any data you have on this or <a href="#{HOME_URL}">other cases</a>.</p>
            HTML
          )
        end
      end

      def send_deletion_email(users:, this_case:)
        title = attr(this_case, :title).to_s

        Array(users).filter_map do |user|
          to = attr(user, :email).to_s.strip
          next if to.empty?

          deliver(
            to: to,
            subject: "The #{title} case has been removed from EBWiki",
            html: <<~HTML
              <h1> **ALERT** #{escape(title)} removal:</h1>
              <p>An EBWiki administrator has removed the #{escape(title)} case from EBWiki.</p>
              <p>Please feel free to let us know if this removal was in error.</p>
            HTML
          )
        end
      end

      def send_mail_enabled?
        ENV["HANAMI_SEND_MAIL"].to_s == "1"
      end

      def smtp_configured?
        !smtp_address.to_s.empty? && !smtp_password.to_s.empty?
      end

      def transmit?
        send_mail_enabled? && smtp_configured? && !test_env?
      end

      private

      def deliver(to:, subject:, html:)
        return if to.to_s.strip.empty?

        message = Message.new(to: to.to_s.strip, from: FROM_ADDRESS, subject: subject, html: html)
        deliveries << message
        log(message)
        transmit(message) if transmit?
        message
      end

      def transmit(message)
        smtp = Net::SMTP.new(smtp_address, smtp_port)
        smtp.enable_starttls_auto if smtp_port != 25
        smtp.start(smtp_domain, smtp_user, smtp_password, smtp_auth) do |session|
          session.send_message(rfc822(message), FROM_ADDRESS, message.to)
        end
      rescue StandardError => error
        warn "EbWiki::Mailer delivery failed: #{error.class}: #{error.message}"
      end

      def rfc822(message)
        [
          "From: #{FROM_NAME} <#{FROM_ADDRESS}>",
          "To: #{message.to}",
          "Subject: #{encoded_subject(message.subject)}",
          "MIME-Version: 1.0",
          "Content-Type: text/html; charset=UTF-8",
          "Content-Transfer-Encoding: 8bit",
          "",
          message.html
        ].join("\r\n")
      end

      def encoded_subject(subject)
        return subject if subject.to_s.ascii_only?

        "=?UTF-8?B?#{Base64.strict_encode64(subject.to_s)}?="
      end

      def smtp_address
        present(ENV["SMTP_ADDRESS"]) || (present(ENV["SENDGRID_USERNAME"]) && "smtp.sendgrid.net")
      end

      def smtp_port
        Integer(ENV.fetch("SMTP_PORT", "587"))
      end

      def smtp_user
        present(ENV["SMTP_USER"]) || present(ENV["SENDGRID_USERNAME"]) || "apikey"
      end

      def smtp_password
        present(ENV["SMTP_PASSWORD"]) || present(ENV["SENDGRID_PASSWORD"]) || present(ENV["SENDGRID_API_KEY"])
      end

      def smtp_domain
        present(ENV["SMTP_DOMAIN"]) || "ebwiki.org"
      end

      def smtp_auth
        (present(ENV["SMTP_AUTH"]) || "plain").to_sym
      end

      def test_env?
        defined?(Hanami) && Hanami.env?(:test)
      end

      def log(message)
        return if test_env?

        $stdout.puts("EbWiki::Mailer: #{message.subject.inspect} -> #{message.to}")
      end

      def attr(record, name)
        if record.respond_to?(name)
          record.public_send(name)
        elsif record.respond_to?(:[])
          record[name]
        end
      end

      def escape(value)
        CGI.escapeHTML(value.to_s)
      end

      def normalize_base(base_url)
        base_url.to_s.chomp("/")
      end

      def present(value)
        string = value.to_s.strip
        string unless string.empty?
      end
    end
  end
end
