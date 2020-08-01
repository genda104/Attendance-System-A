require 'csv'

CSV.generate do |csv|
  column_names = %w(日付 出社 退社 在社時間 備考)
  csv << column_names               #表のカラム名
  @attendances.each do |day|
    if (day.started_at == nil)
      started_at = ""
    else
      started_at = day.started_at.strftime("%H:%M")
    end
    if (day.finished_at == nil)
      finished_at = ""
    else
      finished_at = day.finished_at.strftime("%H:%M")
    end
    if day.started_at.present? && day.finished_at.present?
      temp_working_times = working_times(day.started_at, day.finished_at)
    end
    column_values = [
      day.worked_on.strftime("%m/%d"),
      started_at,
      finished_at,
      temp_working_times,
      day.note
    ]
    csv << column_values            #表のカラム値
  end
end