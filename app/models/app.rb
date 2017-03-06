class App < ApplicationRecord
  include Authority::Abilities

  belongs_to :user

  validates :internal_name, uniqueness: true,  presence: true
  validates :internal_id, uniqueness: true
  validates :user, presence: true

  store %(:android_config :ios_config)

  has_secure_token :internal_id

  def android_hash
    self.android_config.collect{|k,v| [k,v]}
  end

  def android_hash=(param_hash)
    # need to ensure deleted values from form don't persist
    self.android_config.clear
    param_hash.each do |name, value|
      self.android_config[name.to_sym] = value
    end
  end

  def ios_hash
    self.ios_config.collect{|k,v| [k,v]}
  end

  def android_hash=(param_hash)
    # need to ensure deleted values from form don't persist
    self.ios_config.clear
    param_hash.each do |name, value|
      self.ios_config[name.to_sym] = value
    end
  end
end
