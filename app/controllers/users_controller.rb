class UsersController < ApplicationController
  before_action :authenticate_user!

  def index
    if params[:role].present?
      @users = User.where(role: params[:role])
    else
      @users = User.all
    end
  end

  def show
    @user = User.find(params[:id])
  end
end
