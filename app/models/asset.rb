class Asset < ApplicationRecord
  extend FriendlyId
  include CopyCarrierwaveFile

  belongs_to :app
  before_destroy :internal_id

  mount_uploader :file, AssetsUploader

  validates_integrity_of :file
  validates_processing_of :file

  friendly_id :get_filename

  def duplicate_file(original)
    copy_carrierwave_file(original, self, :file)

    self.slug = original.slug
    self.save!
  end

  def internal_id(app_id = self.app_id)
    @internal_id = @internal_id || App.find(app_id).internal_id
  end

  private
  def get_filename
    self.file.filename
  end
end
