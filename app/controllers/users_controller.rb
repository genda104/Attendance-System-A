class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :destroy, :edit_basic_info, :update_basic_info]
  before_action :logged_in_user, only: [:index, :show, :edit, :update, :destroy, :edit_basic_info, :update_basic_info]
  before_action :correct_user, only: [:show, :edit, :update]
  before_action :admin_user, only: [:index, :working_index, :destroy, :edit_basic_info, :update_basic_info]
#  before_action :correct_or_admin_user, only: :show
  before_action :set_one_month, only: :show
  
  def index
    @users = User.all
  end
  
  # 勤怠ページ
  def show
    redirect_to users_url if current_user.admin?                # 管理者の場合はユーザー一覧画面へ
   
    @worked_sum = @attendances.where.not(started_at: nil).count

    @superiors = User.where(superior: true).where.not(id: @user.id)
    @monthly_attendance = @user.attendances.find_by(worked_on: @first_day)
    @monthly_notices = Attendance.where(monthly_status: "申請中", monthly_superior_confirmation: @user.name).count
    @attendance_notices = Attendance.where(edit_status: "申請中", edit_superior_confirmation: @user.name).count
    @overwork_notices = Attendance.where(overwork_request_status: "申請中", overwork_superior_confirmation: @user.name).count

  end
  
  def new
    @user = User.new
  end
  
  def create
    @user = User.new(user_params)
    if @user.save
      flash[:success] = '新規作成に成功しました。'
      redirect_to @user
    else
      render :new
    end
  end
  
  def edit
  end

  def update
    if @user.update_attributes(user_params)
      flash[:success] = "ユーザー情報を更新しました。"
      redirect_to @user
    else
      render :edit
    end
  end
  
  def destroy
    @user.destroy
    flash[:success] = "#{@user.name}のデータを削除しました。"
    redirect_to users_url
  end
  
  def update_basic_info
    if @user.update_attributes(basic_info_params)
      flash[:success] = "#{@user.name}の基本情報を更新しました。"
    else
      flash[:danger] = "#{@user.name}の更新は失敗しました。<br>" + @user.errors.full_messages.join("<br>")
    end
    redirect_to users_url
  end

  # 出社中社員一覧  
  def working_index
    @working_users = []
    temps = []
    @users = User.all.includes(:attendances)
    @users.each do |user|
      if user.attendances.any?{|day|
          ( day.worked_on == Date.current &&
            day.started_at.present? && day.finished_at.blank? )
            }
        temps << user.employee_number          # 条件に合った社員番号を配列変数tempsに格納
      end
    end
    temps.each do |temp|
      @working_users << User.find_by(employee_number: temp)     # 配列変数tempsでユーザーテーブルを検索し@working_usersに格納
    end
  end

  # CSV file import  
  def import
    if params[:file].present?
      if File.extname(params[:file].original_filename) == ".csv" # File.extname とパラメーターのoriginal_filenameでチェック
        ActiveRecord::Base.transaction do       # トランザクションを開始します。
          begin
#            User.import(params[:file]) 
            CSV.foreach(params[:file].path, encoding: 'Shift_JIS:UTF-8', headers: true) do |row|              # headers: trueで1行目をヘッダとして無視
              # テーブルに同じemailが見つかればレコードを呼び出し、見つからなければ新しく作成 (emailフィールドはunique)
              user = User.find_by(email: row["email"]) || new
              # CSVからデータを取得し設定する
              user.attributes = row.to_hash.slice(*updatable_attributes)
              # 保存する
              user.save!
            end
            flash[:success] = 'CSVファイルをインポートしました。'
            redirect_to users_url
            return
          rescue ActiveRecord::RecordInvalid        # トランザクションによる例外発生で更新を無効にする。
            flash[:danger] = "無効な入力データがあった為、以降のインポートをキャンセルしました。"
            redirect_to users_url
          end
        end
      else
        flash[:danger] = "CSVファイルに限ります。インポートできませんでした。"
        redirect_to users_url
      end
    else
      flash[:danger] = "ファイルを選択してください。"
      redirect_to users_url
    end
  end

  # 勤怠ログ
  def attendance_log
    @user = User.find(params[:id])
    if params["select_year(1i)"].present? && params["select_month(2i)"].present? && params["select_month(3i)"].present?
      search_day = params["select_year(1i)"] + "-" +
        format("%02d", params["select_month(2i)"]) + "-" +
        format("%02d", params["select_month(3i)"])
      @first_day = search_day.to_date.beginning_of_month
    else
      @first_day = Date.today.to_date.beginning_of_month
    end
    @last_day = @first_day.end_of_month
    @attendances = @user.attendances.where(edit_status: "承認", worked_on: @first_day..@last_day).order(worked_on: "ASC")
  end
  
  # （各お知らせモーダル内）勤怠確認ボタン
  def confirm_one_month
    attendance = Attendance.find(params[:attendance_id])
    @user = User.find(attendance.user_id)
    @first_day = attendance.worked_on.to_date.beginning_of_month
    @last_day = @first_day.end_of_month
    @attendances = @user.attendances.where(worked_on: @first_day..@last_day).order(:worked_on)
    @worked_sum = @attendances.where.not(started_at: nil).count
  end
  
  # 所属長承認 申請ボタン
  def monthly_approval_request
    @user = User.find(params[:id])
    @attendance = @user.attendances.find_by(worked_on: params[:user][:first_day])
    if params[:user][:monthly_superior_confirmation].present?
      @attendance.monthly_status = "申請中"
      @attendance.update_attributes(monthly_approval_params)
      flash[:success] = "1ヶ月の勤怠を申請しました。"
    else
      flash[:danger] = "所属長を選択して下さい。"
    end
    redirect_to @user
  end

  private
  
    def user_params
      params.require(:user).permit(:name, :email, :affiliation, :employee_number, :uid, :password, :password_confirmation)
    end
    
    def basic_info_params
      params.require(:user).permit(:name, :email, :affiliation, :employee_number, :uid, :password, :basic_work_time, :designated_work_start_time, :designated_work_end_time)
    end
    
    def monthly_approval_params
      params.require(:user).permit(:monthly_superior_confirmation)
    end
    
  # 更新を許可するカラムを定義 CSV file import
    def updatable_attributes
      ["name", "email", "affiliation", "employee_number", "uid", "basic_work_time", "designated_work_start_time", "designated_work_end_time", "superior", "admin", "password"]
    end
  
    # beforeフィルター

    # アクセスしたユーザーが現在ログインしているユーザーか、またはシステム管理者権限所有か確認します。
    def correct_or_admin_user
      unless current_user?(@user) || current_user.admin?
        flash[:danger] = "表示権限がありません。"
        redirect_to root_url
      end
    end
end