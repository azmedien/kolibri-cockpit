class Build < ApplicationRecord
  belongs_to :app
  validates :platform, uniqueness: { scope: :build_id }
end
