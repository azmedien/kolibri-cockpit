class Asset < ApplicationRecord

  include CopyCarrierwaveFile

  mount_uploader :file, AssetsUploader

  validates_integrity_of :file
  validates_processing_of :file

  belongs_to :app

  def duplicate_file(original)
    copy_carrierwave_file(original, self, :file)
    self.save!
  end
end
