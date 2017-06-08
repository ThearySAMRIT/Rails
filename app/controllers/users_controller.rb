class UsersController < ApplicationController

  def show
    @user = User.find_by id: params[:id]

    if @user.nil?
      flash.now[:danger] = t ".note"
      render file: "public/404.html"
    end
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new user_params

    if @user.save
      flash[:success] = t ".welcome"
      redirect_to @user
    else
      flash.now[:danger] = t ".danger"
      render :new
    end
  end

  private

  def user_params
    params.require(:user).permit :name, :email, :password,:password_confirmation
  end

end
