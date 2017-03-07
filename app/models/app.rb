class App < ApplicationRecord
  include Authority::Abilities

  belongs_to :user
  has_many :builds, dependent: :destroy

  validates :internal_name, uniqueness: true,  presence: true
  validates :internal_id, uniqueness: true
  validates :user, presence: true

  store %(:android_config :ios_config)

  has_secure_token :internal_id
end
