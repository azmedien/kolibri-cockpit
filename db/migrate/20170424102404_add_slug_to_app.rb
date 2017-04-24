class AddSlugToApp < ActiveRecord::Migration[5.0]
  def change
    add_column :apps, :slug, :string, unique: true

    say_with_time "Updating slugs of existing applications..." do
      App.all.each do |f|
        f.update_attribute :slug, f.internal_id
      end
    end
  end
end
