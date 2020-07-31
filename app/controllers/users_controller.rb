class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :destroy, :edit_basic_info, :update_basic_info]
  before_action :logged_in_user, only: [:index, :show, :edit, :update, :destroy, :edit_basic_info, :update_basic_info]
  before_action :correct_user, only: [:edit, :update]
  before_action :admin_user, only: [:destroy, :edit_basic_info, :update_basic_info]
  before_action :correct_or_admin_user, only: :show
  before_action :set_one_month, only: :show
  
  def index
    @users = User.all
  end
  
  def show
    @worked_sum = @attendances.where.not(started_at: nil).count
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
  
  def working_index           # 出勤中社員一覧
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
  
  def import                  # CSV file import
    if params[:file].present?
      if File.extname(params[:file].original_filename) == ".csv" # File.extname とパラメーターのoriginal_filenameでチェック
        ActiveRecord::Base.transaction do       # トランザクションを開始します。
          begin
#            User.import(params[:file]) 
            CSV.foreach(params[:file].path, headers: true) do |row|              # headers: trueで1行目をヘッダとして無視
              # テーブルに同じemailが見つかればレコードを呼び出し、見つからなければ新しく作成　(emailフィールドはunique)
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

  private
  
    def user_params
      params.require(:user).permit(:name, :email, :affiliation, :employee_number, :uid, :password, :password_confirmation)
    end
    
    def basic_info_params
      params.require(:user).permit(:name, :email, :affiliation, :employee_number, :uid, :password, :basic_work_time, :designated_work_start_time, :designated_work_end_time)
    end
    
   # 更新を許可するカラムを定義　CSV file import
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