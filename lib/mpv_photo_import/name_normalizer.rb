# frozen_string_literal: true

module MpvPhotoImport
  module NameNormalizer
    SUFFIX_PATTERN = /\s+(jr\.?|sr\.?|ii|iii|iv|v)\z/i

    module_function

    def normalize(name)
      return '' if name.blank?

      cleaned = name.to_s.downcase
      cleaned = cleaned.gsub(SUFFIX_PATTERN, '')
      cleaned = cleaned.gsub(/[^a-z0-9\s]/, ' ')
      cleaned.split.join(' ')
    end
  end
end
