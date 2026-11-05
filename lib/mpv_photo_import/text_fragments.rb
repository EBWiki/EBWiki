# frozen_string_literal: true

module MpvPhotoImport
  module TextFragments
    module_function

    def haystack_includes_any?(haystack, fragments)
      fragments.each do |fragment|
        return true if haystack.include?(fragment)
      end

      false
    end
  end
end
