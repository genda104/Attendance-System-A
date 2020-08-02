class BasesController < ApplicationController
  before_action :set_base, only: [:show, :update, :destroy]
  before_action :admin_user
  
  def index
    @bases = Base.all.order('base_id ASC')
    @base = Base.new
  end
  
  def new
  end
  
  def create
    @base = Base.new(base_params)
    if @base.save
      flash[:success] = '拠点情報を追加しました。'  
      redirect_to bases_url
    else
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
      render :index
    end
  end
  
  
  private
  
    def set_base
      @base = Base.find(params[:id])
    end
    
    def base_params
      params.require(:base).permit(:base_id, :name, :attendance)
    end
end
