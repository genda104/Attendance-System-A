class AddColumnToAttendances < ActiveRecord::Migration[5.1]
  def change
    # 1ヶ月勤怠承認
    add_column :attendances, :monthly_status, :string                   # 1ヶ月承認の状態
    add_column :attendances, :monthly_superior_confirmation, :string    # 1ヶ月承認指示者確認
    # 勤怠編集
    add_column :attendances, :edit_started_at, :datetime                # 変更出社時間
    add_column :attendances, :edit_finished_at, :datetime               # 変更退社時間
    add_column :attendances, :before_started_at, :datetime              # 変更前出社時間
    add_column :attendances, :before_finished_at, :datetime             # 変更前退社時間
    add_column :attendances, :edit_next_day, :boolean                   # 変更翌日チェック
    add_column :attendances, :before_next_day, :boolean                 # 変更前翌日チェック
    add_column :attendances, :next_day, :boolean                        # 翌日チェック
    add_column :attendances, :edit_status, :string                      # 勤怠編集の状態
    add_column :attendances, :edit_superior_confirmation, :string       # 勤怠編集指示者確認
    add_column :attendances, :approval_date, :date                      # 承認日
    # 残業申請
    add_column :attendances, :scheduled_end_time, :datetime             # 終了予定時間
    add_column :attendances, :overwork_next_day, :boolean               # 翌日チェック
    add_column :attendances, :work_details, :string                     # 業務処理内容
    add_column :attendances, :overwork_request_status, :string          # 残業申請の状態
    add_column :attendances, :overwork_superior_confirmation, :string   # 残業申請指示者確認
    add_column :attendances, :change, :boolean                          # 変更のチェック
  end
end
