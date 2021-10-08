# frozen_string_literal: true

# == Schema Information
#
# Table name: links
#
#  id            :integer          not null, primary key
#  linkable_type :string
#  title         :string
#  url           :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  linkable_id   :integer
#
# Indexes
#
#  index_links_on_linkable_id                    (linkable_id)
#  index_links_on_linkable_id_and_linkable_type  (linkable_id,linkable_type)
#
# Foreign Keys
#
#  fk_rails_...  (linkable_id => cases.id)
#
# associate Case property
class Link < ApplicationRecord
  validates :url, presence: true
  belongs_to :linkable, polymorphic: true, touch: true
end
