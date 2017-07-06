class AppsAuthorizer < ApplicationAuthorizer

  def deletable_by?(user)
    resource.user == user
  end
end
