# frozen_string_literal: true

module CasePhotoTestData
  module_function

  def attach_test_avatar(case_record)
    path = Rails.root.join('spec/fixtures/files/test_avatar.png')
    case_record.avatar = File.open(path)
    case_record.save!
    case_record
  end
end
