class CreateActivities < ActiveRecord::Migration[5.2]
  def change
    create_table :activities do |t|
      t.string :action
      t.string :comments

      t.timestamps
    end
  end
end
