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

      CARRIERWAVE_VERSIONS = {
        large: "large_avatar",
        medium: "medium_avatar",
        small: "small_avatar",
        thumb: "thumb"
      }.freeze

      def case_image_url(this_case, version: :large)
        url = this_case.default_avatar_url.to_s
        return url unless url.empty?

        filename = this_case.avatar.to_s
        return if filename.empty?

        prefix = CARRIERWAVE_VERSIONS.fetch(version) { version.to_s }
        object_key = "uploads/case/avatar/#{this_case.id}/#{prefix}_#{filename}"
        carrierwave_asset_url(object_key)
      end

      def carrierwave_asset_url(object_key)
        bucket = ENV["S3_BUCKET"].to_s
        return "/#{object_key}" if bucket.empty?

        region = ENV["S3_REGION"].to_s
        host = if region.empty?
          "https://#{bucket}.s3.amazonaws.com"
        else
          "https://#{bucket}.s3.#{region}.amazonaws.com"
        end
        "#{host}/#{object_key}"
      end

      def version_author_name(version, authors)
        user = authors[version.author_id] || authors[integer_id(version.whodunnit)]
        return user.name if user
        return "Guest" if version.whodunnit.to_s.empty? || version.whodunnit == "Guest"

        "User #{version.whodunnit}"
      end

      def integer_id(value)
        return if value.to_s.strip.empty?

        Integer(value)
      rescue ArgumentError
        nil
      end

      def attr_of(record, key)
        return if record.nil?
        return record.public_send(key) if record.respond_to?(key)

        record[key]
      end

      def truncate_text(text, length)
        str = text.to_s
        return str if str.length <= length

        "#{str[0, length].rstrip}…"
      end
    end
  end
end
