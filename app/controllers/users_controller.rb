class UsersController < ApplicationController
  before_action :logged_in_user, except: :show
  before_action :correct_user, only: [:edit, :update, :show]
  before_action :verify_admin!, only: :destroy

  def index
    @users = User.select(:id, :name, :email).order(name: :asc)
    .paginate page: params[:page], per_page: Settings.paginate.page_number
  end

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
      @user.send_activation_email
      flash[:success] = t ".welcome"
      flash[:info] = t ".checkout"
      redirect_to @user
    else
      flash.now[:danger] = t ".danger"
      render :new
    end
  end

  def edit
    @user = User.find params[:id]
  end

  def update
    @user = User.find params[:id]
    if @user.update_attributes user_params
      flash[:success] = t ".updated"
      redirect_to @user
    else
      flash[:danger] = t ".noupdate"
      render :edit
    end
  end

  def destroy
    User.find(params[:id]).destroy
    flash[:success] = t ".deleted"
    redirect_to users_url
  end

  private

  def user_params
    params.require(:user).permit :name, :email, :password,:password_confirmation
  end

  def logged_in_user
    unless logged_in?
      store_location
      flash[:danger] = t ".please"
      redirect_to login_url
    end
  end

  def correct_user
    @user = User.find_by params[:id]
    redirect_to root_url unless current_user? @user
  end

  def verify_admin!
    redirect_to root_url unless current_user.admin?
  end
end
