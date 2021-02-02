class AttendancesController < ApplicationController
  before_action :set_user, only: [:edit_one_month, :update_one_month]
  before_action :logged_in_user, only: [:update, :edit_one_month]
  before_action :admin_or_correct_user, only: [:update, :edit_one_month, :update_one_month]
  before_action :set_one_month, only: :edit_one_month
  
  UPDATE_ERROR_MSG = "勤怠登録に失敗しました。やり直してください。"
  
  def update
    @user = User.find(params[:user_id])
    @attendance = Attendance.find(params[:id])
    # 出勤時間が未登録であることを判定します。
    if @attendance.started_at.nil?
      if @attendance.update_attributes(started_at: Time.current.change(sec: 0))
        flash[:info] = "おはようございます！"
      else
        flash[:danger] = UPDATE_ERROR_MSG
      end
    elsif @attendance.finished_at.nil?
      if @attendance.update_attributes(finished_at: Time.current.change(sec: 0))
        flash[:info] = "お疲れ様でした。"
      else
        flash[:danger] = UPDATE_ERROR_MSG
      end
    end
    redirect_to @user
  end
  
  # １ヶ月の勤怠編集
  def edit_one_month
    respond_to do |format|
      format.html do
        @superiors = User.where(superior: true).where.not(id: @user.id)             # html用の処理を書く
      end
      format.csv do
        send_data render_to_string, filename: "当月分勤怠データ.csv", type: :csv       # csv用の処理を書く
      end
    end
  end
  
  # １ヶ月の勤怠更新
  def update_one_month
    superior_count = 0
    ActiveRecord::Base.transaction do                        # トランザクションを開始します。
      attendances_params.each do |id, item|
        attendance = Attendance.find(id)
        if item[:edit_superior_confirmation].present?
          superior_count += 1
          if item[:started_at].blank? || item[:finished_at].blank?
            if item[:started_at].blank? && (attendance.worked_on == Date.today)
              flash[:danger] = "出社が入力されていません。"
              redirect_to attendances_edit_one_month_user_url(date: params[:date]) and return
            elsif item[:finished_at].blank? && (attendance.worked_on == Date.today)           # 当日は退社なしでも可
            else
              flash[:danger] = "出社・退社が入力されていません。"
              redirect_to attendances_edit_one_month_user_url(date: params[:date]) and return
            end
          elsif ((item[:started_at] > item[:finished_at]) && (item[:next_day] == "0"))
            flash[:danger] = "出社時間より早い退社時間は無効です。"
            redirect_to attendances_edit_one_month_user_url(date: params[:date]) and return
          end
          item[:edit_status] = "申請中"
          attendance.update_attributes!(item)
        end
      end
    end
    if superior_count > 0
      flash[:success] = "勤怠変更申請を送信しました。"
    end
    redirect_to user_url(date: params[:date]) and return
  rescue ActiveRecord::RecordInvalid                        # トランザクションによる例外発生で更新を無効にする。
    flash[:danger] = "無効な入力データがあった為、更新をキャンセルしました。例外発生！"
    redirect_to attendances_edit_one_month_user_url(date: params[:date])
  end
 
  # 所属長承認申請モーダル表示
  def edit_monthly_approval
    @user = User.find(params[:user_id])
    @attendances = Attendance.where(monthly_status: "申請中", monthly_superior_confirmation: @user.name).order(user_id: "ASC", worked_on: "ASC").group_by(&:user_id)
  end

  # 所属長承認申請モーダル更新
  def update_monthly_approval
    @user = User.find(params[:user_id])
    ActiveRecord::Base.transaction do
      monthly_params.each do |id, item|
        if item[:change] == "1"
          attendance = Attendance.find(id)
          if item[:monthly_status] == "承認"
            item[:change] = "0"
            attendance.update_attributes!(item)
            flash[:success] = "申請を承認しました。"
          elsif item[:monthly_status] == "否認"
            item[:change] = "0"
            attendance.update_attributes!(item)
            flash[:danger] = "申請を否認しました。"
          else
            item[:change] = "0"
            attendance.update_attributes!(item)
          end
        end
      end
    end
    redirect_to @user
  rescue ActiveRecord::RecordInvalid
    flash[:danger] = "無効な入力データがあった為、変更をキャンセルしました。"
    redirect_to @user
  end
  
  # 勤怠変更申請モーダル
  def edit_attendance_approval
    @user = User.find(params[:user_id])
    @attendances = Attendance.where(edit_status: "申請中", edit_superior_confirmation: @user.name).order(user_id: "ASC", worked_on: "ASC").group_by(&:user_id)
  end
  
  # 勤怠変更申請モーダル更新
  def update_attendance_approval
    approval_count = 0
    @user = User.find(params[:user_id])
    ActiveRecord::Base.transaction do
      edit_attendances_params.each do |id, item|
        if item[:change] == "1"
          attendance = Attendance.find(id)
          if item[:edit_status] == "承認"
            approval_count += 1
            if attendance.before_started_at.blank?
              attendance.before_started_at = attendance.started_at
            end
            if attendance.before_finished_at.blank?
              attendance.before_finished_at = attendance.finished_at
              attendance.before_next_day = attendance.next_day
            end
            attendance.edit_started_at = attendance.started_at
            attendance.edit_finished_at = attendance.finished_at
            attendance.edit_next_day = attendance.next_day
            attendance.previous_note = attendance.note
            attendance.previous_edit_status = "承認"
            item[:change] = "0"
            item[:approval_date] = Date.current
            attendance.update_attributes!(item)
          elsif item[:edit_status] == "否認"
            approval_count += 1
            unless attendance.edit_started_at.blank?
              attendance.started_at = attendance.edit_started_at
            end
            unless attendance.edit_finished_at.blank?
              attendance.finished_at = attendance.edit_finished_at
              attendance.next_day = attendance.edit_next_day
            end
            attendance.previous_note = attendance.note
            attendance.previous_edit_status = "否認"
            item[:change] = "0"
            attendance.update_attributes!(item)
          else
            unless attendance.edit_started_at.blank?
              attendance.started_at = attendance.edit_started_at
            end
            unless attendance.edit_finished_at.blank?
              attendance.finished_at = attendance.edit_finished_at
              attendance.next_day = attendance.edit_next_day
            end
            item[:note] = attendance.previous_note
            item[:edit_status] = attendance.previous_edit_status
            item[:change] = "0"
            attendance.update_attributes!(item)
          end
        end
      end
    end
    if approval_count > 0
      flash[:success] = "勤怠変更申請の返信をしました。"
    end
    redirect_to @user
  rescue ActiveRecord::RecordInvalid
    flash[:danger] = "無効な入力データがあった為、変更をキャンセルしました。"
    redirect_to @user
  end
  
  # 残業申請モーダル
  def edit_overwork_request
    @user = User.find(params[:user_id])
    @attendance = @user.attendances.find(params[:id])
    @superiors = User.where(superior: true).where.not(id: @user.id)
  end
  
  # 残業申請モーダル更新
  def update_overwork_request
    @user = User.find(params[:user_id])
    @attendance = @user.attendances.find(params[:id])
    if params[:attendance][:work_details].blank? || params[:attendance][:overwork_superior_confirmation].blank?
      flash[:danger] = "未入力の項目があります。"
    else
      @attendance.overwork_request_status = "申請中"
      @attendance.update_attributes(overwork_params)
      flash[:success] = "残業を申請しました。"
    end
    redirect_to @user
  end

  # 残業申請お知らせモーダル
  def edit_overwork_approval
    @user = User.find(params[:user_id])
    @attendances = Attendance.where(overwork_request_status: "申請中", overwork_superior_confirmation: @user.name).order(user_id: "ASC", worked_on: "ASC").group_by(&:user_id)
  end
  
  # 残業申請お知らせモーダル更新
  def update_overwork_approval
    approval_count = 0
    @user = User.find(params[:user_id])
    ActiveRecord::Base.transaction do
      overwork_notice_params.each do |id, item|
        if item[:change] == "1"
          attendance = Attendance.find(id)
          if item[:overwork_request_status].in?(["承認", "否認"])
            approval_count += 1
            item[:change] = "0"
            attendance.update_attributes!(item)
          else
            item[:change] = "0"
            attendance.update_attributes!(item)
          end
        end
      end
    end
    if approval_count > 0
      flash[:success] = "残業申請の返信をしました。"
    end
    redirect_to @user
  rescue ActiveRecord::RecordInvalid
    flash[:danger] = "無効な入力データがあった為、変更をキャンセルしました。"
    redirect_to @user
  end

  private

    # 1ヶ月分の勤怠情報を扱います。
    def attendances_params
      params.require(:user).permit(attendances: [:started_at, :finished_at, :note, :edit_superior_confirmation, :next_day])[:attendances]
    end
    
    # 1ヶ月の勤怠申請の更新情報
    def monthly_params
      params.require(:user).permit(attendances: [:monthly_status, :change])[:attendances]
    end
    
    # 勤怠変更申請の更新情報
    def edit_attendances_params
      params.require(:user).permit(attendances: [:edit_status, :change, :approval_date])[:attendances]
    end

    # 残業申請の更新情報
    def overwork_params
      params.require(:attendance).permit(:scheduled_end_time, :overwork_next_day, :work_details, :overwork_superior_confirmation)
    end
    
    # 残業申請お知らせの更新情報
    def overwork_notice_params
      params.require(:user).permit(attendances: [:overwork_request_status, :change])[:attendances]
    end

    # beforeフィルター

    # 管理権限者、または現在ログインしているユーザーを許可します。
    def admin_or_correct_user
      @user = User.find(params[:user_id]) if @user.blank?
      unless current_user?(@user) || current_user.admin?
        flash[:danger] = "編集権限がありません。"
        redirect_to root_url
      end  
    end    
end
