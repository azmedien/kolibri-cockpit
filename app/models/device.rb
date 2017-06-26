class Device < ApplicationRecord

  enum platform: [ :android, :ios ]

  validates :token, uniqueness: true,  presence: true
  validates :platform, presence: true

  belongs_to :app
end
