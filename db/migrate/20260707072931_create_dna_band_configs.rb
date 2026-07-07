class CreateDnaBandConfigs < ActiveRecord::Migration[8.1]
  def change
    create_table :dna_band_configs do |t|
      t.references :experiment, null: false, foreign_key: true
      t.string :sample_name
      t.integer :well_number
      t.jsonb :band_positions
      t.string :correct_genotype

      t.timestamps
    end

    add_index :dna_band_configs, [:experiment_id, :well_number], unique: true
  end
end
