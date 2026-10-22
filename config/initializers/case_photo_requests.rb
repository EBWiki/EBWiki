# frozen_string_literal: true

config_path = Rails.root.join('config/case_photo_requests.yml')
settings = if config_path.exist?
             YAML.safe_load_file(config_path, aliases: true)[Rails.env] || {}
           else
             {}
           end

Rails.application.config.x.case_photo_requests = settings.deep_symbolize_keys
