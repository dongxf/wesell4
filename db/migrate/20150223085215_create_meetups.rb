class CreateMeetups < ActiveRecord::Migration
  def change
    create_table :meetups do |t|
      t.text :comment
      t.string :name

      t.timestamps
    end
  end
end
