class ToWaTestMigration < ActiveRecord::Migration[5.1]
  class << self
    def up
      create_table(:users) do |t|
        t.integer :left_arm_length
        t.integer :right_arm_length
        t.references :test_record
      end

      create_table(:test_records) do |t|
        t.string :a
        t.string :b
        t.string :c
        t.integer :x
        t.integer :y
        t.integer :z
        t.string :denied_column
      end
    rescue
      nil
    end

    def down
      begin
        drop_table(:users)
      rescue
        nil
      end
      begin
        drop_table(:test_records)
      rescue
        nil
      end
    end
  end
end
