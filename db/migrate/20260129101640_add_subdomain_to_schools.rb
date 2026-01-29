class AddSubdomainToSchools < ActiveRecord::Migration[8.1]
  def change
    add_column :schools, :subdomain, :string
    add_index :schools, :subdomain, unique: true
  end
end
