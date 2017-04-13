class Asset < ApplicationRecord
  mount_uploader :file, AssetsUploader

  validates_integrity_of :file
  validates_processing_of :file

  belongs_to :app
end
