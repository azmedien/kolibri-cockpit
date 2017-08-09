class AppsAuthorizer < ApplicationAuthorizer

  def readable_by?(user)
    user.has_role? :admin, resource
  end

  def updatable_by?(user)
    user.has_role? :admin, resource
  end

  def deletable_by?(user)
    resource.user == user
  end

  def buildable_by?(user)
    user.has_role? :admin, resource
  end

  def preparable_by?(user)
    user.has_role? :admin, resource
  end

  def notifyable_by?(user)
    user.has_any_role? :admin, { :name => :admin, :resource => resource }, { :name => :notifier, :resource => resource }
  end

  def publishable_by?(user)
    user.has_any_role? :admin, { :name => :admin, :resource => resource }, { :name => :publisher, :resource => resource }
  end
end
