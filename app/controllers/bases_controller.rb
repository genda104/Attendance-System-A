class BasesController < ApplicationController
  before_action :set_base, only: [:show, :edit, :update, :destroy]
  before_action :admin_user
  
  def index
    @base = Base.new
    @bases = Base.all.order('base_id ASC')
  end

  def show
  end
  
  def new
    @base = Base.new
  end
  
  def create
    @base = Base.new(base_params)
    if @base.save
      flash[:success] = '拠点情報を作成しました。'  
      redirect_to bases_url
    else
      @bases = Base.all.order('base_id ASC')
#      flash[:danger] = '拠点情報の作成に失敗しました。'
      render :index
    end
  end
  
  def edit
  end

  def update
    if @base.update_attributes(base_params)
      flash[:success] = "拠点情報を更新しました。"
      redirect_to bases_url
    else
      @bases = Base.all.order('base_id ASC')
#      flash[:danger] = '拠点情報の更新に失敗しました。'
      render :index
    end
  end
  
  def destroy
    @base.destroy
    flash[:success] = "#{@base.name}のデータを削除しました。"
    redirect_to bases_url
  end
  
  private
  
    def set_base
      @base = Base.find(params[:id])
    end
    
    def base_params
      params.require(:base).permit(:base_id, :name, :attendance)
    end
end
