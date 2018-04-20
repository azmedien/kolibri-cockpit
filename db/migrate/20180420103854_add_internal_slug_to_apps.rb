class AddInternalSlugToApps < ActiveRecord::Migration[5.1]
  def change
    add_column :apps, :internal_slug, :string
    add_index :apps, :internal_slug, unique: true

    App.reset_column_information

    say_with_time 'Updating internal_slug of existing applications...' do
      App.all.each do |f|
        f.update_attribute :internal_slug, f.internal_name.parameterize
      end
    end

    change_column :apps, :internal_slug, :string, null: false
  end
end
