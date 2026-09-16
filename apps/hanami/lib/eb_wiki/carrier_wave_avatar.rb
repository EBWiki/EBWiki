# frozen_string_literal: true

require "fileutils"
require "open3"
require "pathname"
require "tmpdir"
require "eb_wiki/s3"

module EbWiki
  # Writes case avatars using the same object keys CarrierWave already uses:
  # uploads/case/avatar/:id/:filename and version prefixes large_avatar_,
  # medium_avatar_, small_avatar_, thumb_.
  class CarrierWaveAvatar
    VERSIONS = {
      "large_avatar" => [250, 250],
      "medium_avatar" => [150, 150],
      "small_avatar" => [35, 35],
      "thumb" => [50, 50]
    }.freeze
    ALLOWED_EXT = %w[.jpg .jpeg .gif .png].freeze

    class << self
      def store(record:, upload:)
        file = normalize(upload)
        return unless file && record

        filename = sanitize(file[:filename])
        return unless filename

        bytes = File.binread(file[:tempfile].path)
        return if bytes.to_s.empty?

        keys = object_keys(record.id, filename)
        content_type = content_type_for(filename)
        ok = keys.all? do |kind, key|
          body = version_bytes(bytes, kind, filename)
          write_object(key, body, content_type)
        end
        return unless ok

        {filename: filename, default_avatar_url: public_url(keys.fetch(:original))}
      end

      def remove(record)
        return unless record

        filename = record.respond_to?(:avatar) ? record.avatar : record[:avatar]
        return if filename.to_s.empty?

        object_keys(record.id, filename).each_value { |key| delete_object(key) }
        true
      end

      def object_keys(case_id, filename)
        prefix = "uploads/case/avatar/#{case_id}"
        keys = {original: "#{prefix}/#{filename}"}
        VERSIONS.each_key do |version|
          keys[version] = "#{prefix}/#{version}_#{filename}"
        end
        keys
      end

      def public_url(object_key)
        bucket = ENV["S3_BUCKET"].to_s
        return "/#{object_key}" if bucket.empty?

        region = ENV["S3_REGION"].to_s
        host = if region.empty? || region == "us-east-1"
          "https://#{bucket}.s3.amazonaws.com"
        else
          "https://#{bucket}.s3.#{region}.amazonaws.com"
        end
        "#{host}/#{object_key}"
      end

      private

      def normalize(upload)
        return if upload.nil? || upload == ""

        if upload.respond_to?(:tempfile) && upload.respond_to?(:original_filename)
          {tempfile: upload.tempfile, filename: upload.original_filename}
        elsif upload.respond_to?(:[])
          tempfile = upload[:tempfile] || upload["tempfile"]
          filename = upload[:filename] || upload["filename"] || upload[:original_filename]
          return unless tempfile && filename

          {tempfile: tempfile, filename: filename}
        end
      end

      def sanitize(name)
        return if name.to_s.include?("..")

        base = File.basename(name.to_s)
        return if base.empty? || base.start_with?(".")

        ext = File.extname(base).downcase
        return unless ALLOWED_EXT.include?(ext)

        base
      end

      def content_type_for(filename)
        case File.extname(filename).downcase
        when ".png" then "image/png"
        when ".gif" then "image/gif"
        else "image/jpeg"
        end
      end

      def version_bytes(original, kind, filename)
        return original if kind == :original

        size = VERSIONS[kind.to_s]
        return original unless size

        resize(original, size, filename) || original
      end

      def resize(bytes, size, filename)
        return unless convert?

        Dir.mktmpdir do |dir|
          source = File.join(dir, "source#{File.extname(filename)}")
          dest = File.join(dir, "dest#{File.extname(filename)}")
          File.binwrite(source, bytes)
          w, h = size
          geometry = "#{w}x#{h}^"
          _out, _err, status = Open3.capture3(
            "convert", source, "-resize", geometry, "-gravity", "center", "-extent", "#{w}x#{h}", dest
          )
          next unless status.success? && File.file?(dest)

          File.binread(dest)
        end
      rescue Errno::ENOENT
        nil
      end

      def convert?
        return @convert if defined?(@convert)

        _out, _err, status = Open3.capture3("convert", "-version")
        @convert = status.success?
      rescue Errno::ENOENT
        @convert = false
      end

      def write_object(key, body, content_type)
        if EbWiki::S3.configured?
          EbWiki::S3.put(key, body, content_type: content_type)
        else
          path = local_root.join(key)
          FileUtils.mkdir_p(path.dirname)
          File.binwrite(path, body)
          true
        end
      end

      def delete_object(key)
        if EbWiki::S3.configured?
          EbWiki::S3.delete(key)
        else
          path = local_root.join(key)
          FileUtils.rm_f(path)
        end
      end

      def local_root
        configured = ENV["LOCAL_UPLOAD_ROOT"].to_s
        return Pathname(configured) unless configured.empty?
        return Hanami.app.root.join("public") if defined?(Hanami)

        Pathname.pwd.join("public")
      end
    end
  end
end
