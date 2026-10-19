# frozen_string_literal: true

module LegacyCasePhotoColumns
  def update_legacy_case_photo_columns(
    case_record,
    avatar: nil,
    default_avatar_url: nil,
    remove_avatar: nil
  )
    Case.connection.exec_update(
      Case.sanitize_sql_array(
        [
          'UPDATE cases SET avatar = ?, default_avatar_url = ?, remove_avatar = ? WHERE id = ?',
          avatar,
          default_avatar_url,
          remove_avatar,
          case_record.id
        ]
      )
    )
  end
end

RSpec.configure do |config|
  config.include LegacyCasePhotoColumns
end
