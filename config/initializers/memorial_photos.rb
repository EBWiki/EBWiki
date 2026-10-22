# frozen_string_literal: true

config_path = Rails.root.join('config/memorial_photos.yml')
settings = if config_path.exist?
             YAML.safe_load_file(config_path, aliases: true)[Rails.env] || {}
           else
             {}
           end

Rails.application.config.x.memorial_photos = settings.deep_symbolize_keys
