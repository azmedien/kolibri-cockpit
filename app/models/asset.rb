class Asset < ApplicationRecord
  mount_uploader :file, AssetsUploader
  belongs_to :app
end
