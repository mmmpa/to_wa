class ToWaTestMigration < ActiveRecord::Migration[5.1]
  class << self
    def up
      create_table(:test_records) do |t|
        t.string :a
        t.string :b
        t.string :c
        t.integer :x
        t.integer :y
        t.integer :z
      end
    rescue
      nil
    end

    def down
      drop_table(:test_records)
    rescue
      nil
    end
  end
end
