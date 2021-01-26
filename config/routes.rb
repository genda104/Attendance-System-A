Rails.application.routes.draw do
  root 'static_pages#top'
  get '/signup', to: 'users#new'
  
  # ログイン機能
  get    '/login', to: 'sessions#new'
  post   '/login', to: 'sessions#create'
  delete '/logout', to: 'sessions#destroy'

  resources :users do
    member do
      get 'edit_basic_info'                       # 基本情報編集
      patch 'update_basic_info'                   # 基本情報更新
      get 'attendances/edit_one_month'            # １ヶ月の勤怠編集
      patch 'attendances/update_one_month'        # １ヶ月の勤怠更新
      patch 'monthly_approval_request'            # 所属長承認申請ボタン
      get 'confirm_one_month'                     # 承認画面内の確認ボタン
      get 'attendance_log'                        # 勤怠ログ
    end
    collection do
      post :import                                # CSVインポート
      get :working_index                          # 出勤中社員一覧
    end
    resources :attendances, only: :update do
      member do
        get 'edit_overwork_request'               # 残業申請モーダル表示
        patch 'update_overwork_request'           # 残業申請モーダル更新
      end
      collection do
        get 'edit_monthly_approval'               # 1ヶ月勤怠申請お知らせモーダル表示
        patch 'update_monthly_approval'           # 1ヶ月勤怠申請お知らせモーダル更新
        get 'edit_attendance_approval'            # 勤怠変更申請お知らせモーダル表示
        patch 'update_attendance_approval'        # 勤怠変更申請お知らせモーダル更新
        get 'edit_overwork_approval'              # 残業申請お知らせモーダル表示
        patch 'update_overwork_approval'          # 残業申請お知らせモーダル更新
      end
    end
  end

  # 拠点情報
  resources :hubs
  # システムの基本情報
  get '/system', to: 'static_pages#system'

end
