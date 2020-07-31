require 'csv'

CSV.generate do |csv|
  column_names = %w(日付 出社 退社 備考)
  csv << column_names               #表のカラム名
  @attendances.each do |f|
    if (f.started_at == nil)
      started_at = ""
    else
      started_at = f.started_at.strftime("%H:%M")
    end
    if (f.finished_at == nil)
      finished_at = ""
    else
      finished_at = f.finished_at.strftime("%H:%M")
    end
    column_values = [
      f.worked_on.strftime("%m/%d"),
      started_at,
      finished_at,
      f.note
    ]
    csv << column_values            #表のカラム値
  end
end