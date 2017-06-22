class PasswordResetsController < ApplicationController
  before_action :check_expiration, :load_user, :valid_user, only: [:edit, :update]

  def new
  end

  def create
    @user = User.find_by email: params[:password_reset][:email].downcase

    if @user
      @user.create_reset_digest
      @user.send_password_reset_email
      flash[:info] = t ".email_send_reset_password"
      redirect_to root_url
    else
      flash.now[:danger] = t ".not_found"
      render :new
    end
  end

  def edit
  end

  def update
    if params[:user][:password].empty?
      @user.errors.add :password, t ".not_empty"
      render :edit
    elsif @user.update_attributes user_params
      log_in @user
      @user.update_attribute :reset_digest, nil
      flash[:success] = t. "has_been_reset"
      redirect_to @user
    else
      render :edit
    end
  end

  private

  def user_params
    params.require :user.permit :password, :password_confirmation
  end

  def load_user
    @user = User.find_by email: params[:email]
    valid_info @user
  end

  def valid_user
    return if @user && @user.activated? && @user.authenticated?(:reset, params[:id])
    redirect_to root_url
  end

  def check_expiration
    if @user.password_reset_expired?
      flash[:danger] = t ".expired"
      redirect_to new_password_reset_url
    end
  end
end
