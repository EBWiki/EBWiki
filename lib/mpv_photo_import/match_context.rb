# frozen_string_literal: true

module MpvPhotoImport
  MatchContext = Data.define(
    :mpv_name,
    :mpv_date,
    :mpv_state_code,
    :case_title,
    :case_date,
    :case_state_code
  )
end
