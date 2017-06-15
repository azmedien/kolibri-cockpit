class Build < ApplicationRecord
  belongs_to :app
  belongs_to :user

  validates :platform, uniqueness: { scope: :build_id }
end
