class AccountActivationsController < ApplicationController
  def edit
    user = User.find_by email: params[:email]

    if user && !user.activated? && user.authenticated?(:activation, params[:id])
      user.activatie
      log_in user
      flash[:success] = t ".activate"
      redirect_to user
    else
      flash[:danger] = t ".link"
      redirect_to root_url
    end
  end
end
