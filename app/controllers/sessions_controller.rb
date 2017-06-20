class SessionsController < ApplicationController
  def new
  end

  def create
    user = User.find_by email: params[:session][:email].downcase

    if user && user.authenticate(params[:session][:password])
      if user.activated?
        log_in user
        params[:session][:remember_me] == "1" ? remember(user) : forget(user)
        redirect_back_or user
      else
        flash.now[:warning] = t ".account_not_activate." + t ".check"
        redirect_to root_url
      end
    end
  end

  def destroy
    log_out
    redirect_to root_url
  end
end
