class CreateSlacks < ActiveRecord::Migration[5.0]
  def change
    create_table :slacks do |t|
      t.string :name

      t.timestamps
    end
  end
end