class StaticPagesController < ApplicationController
  before_action :admin_user, only: [:system]
  
  def top
  end

  def system
  end
  
end
