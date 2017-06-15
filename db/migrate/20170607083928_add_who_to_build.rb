class AddWhoToBuild < ActiveRecord::Migration[5.0]
  def change
    add_reference :builds, :user, index: true

    Build.all.each do |build|
      build.update_attribute :user, build.app.user
    end
  end
end
