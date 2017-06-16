class DisallowNullInBuilds < ActiveRecord::Migration[5.0]
  def change
    change_column_null :builds, :code, false
  end
end
