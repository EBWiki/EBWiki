class Document < ActiveRecord::Base
  mount_uploader :attachment, AttachmentUploader
  validates :title, presence: true

  has_many :article_documents, dependent: :destroy
  has_many :articles, through: :article_documents
  accepts_nested_attributes_for :article_documents, :reject_if => :all_blank, :allow_destroy => true

end
