class AddSuperiorIdToAttendances < ActiveRecord::Migration[5.1]
  def change
    add_column :attendances, :superior_id, :integer
  end
end
