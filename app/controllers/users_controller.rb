class UsersController < ApplicationController
  before_action :authenticate_user!

  def index
    @students = User.where(role: :student)
    @faculty  = User.where(role: :faculty)
  end

  def show
    @user = User.find(params[:id])
  end
end
