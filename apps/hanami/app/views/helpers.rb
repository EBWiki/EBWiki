# auto_register: false
# frozen_string_literal: true

require "sanitize"

module EbWiki
  module Views
    module Helpers
      CAUSE_OF_DEATH_LABELS = {
        "beating" => "Beating",
        "bombing" => "Bombing",
        "chemical_agents_or_weapons" => "Chemical Agents or Weapons",
        "choking" => "Choking",
        "drowning" => "Drowning",
        "medical neglect" => "Medical Neglect",
        "medical_neglect" => "Medical Neglect",
        "response to medical emergency" => "Response to Medical Emergency",
        "response_to_medical_emergency" => "Response to Medical Emergency",
        "shooting" => "Shooting",
        "stabbing" => "Stabbing",
        "suicide" => "Suicide",
        "taser" => "Taser",
        "vehicular" => "Vehicular"
      }.freeze

      def format_date(date)
        return if date.nil?

        date.strftime("%B %-d, %Y")
      end

      def format_time(time)
        return if time.nil?

        time.strftime("%B %-d, %Y")
      end

      def cause_of_death_label(value)
        return CAUSE_OF_DEATH_LABELS.fetch("unknown", "Not Yet Known") if value.to_s.empty?

        CAUSE_OF_DEATH_LABELS.fetch(value.to_s, value.to_s.tr("_", " ").split.map(&:capitalize).join(" "))
      end

      def rich_text(html)
        Sanitize.fragment(html.to_s, Sanitize::Config::RELAXED)
      end

      def case_image_url(this_case)
        url = this_case.default_avatar_url.to_s
        return url unless url.empty?

        filename = this_case.avatar.to_s
        return "/uploads/case/avatar/#{this_case.id}/#{filename}" unless filename.empty?

        nil
      end

      def truncate_text(text, length)
        str = text.to_s
        return str if str.length <= length

        "#{str[0, length].rstrip}…"
      end
    end
  end
end
