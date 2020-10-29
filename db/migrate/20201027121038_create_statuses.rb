class CreateStatuses < ActiveRecord::Migration[5.2]
  def change
    create_table :statuses do |t|
      t.string :status_id
      t.string :integer
      t.string :description

      t.timestamps
    end
  end
end
