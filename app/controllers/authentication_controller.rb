class AuthenticationController < ApplicationController

  respond_to :json

  def authenticate
    username = params[:username]
    user = User.find_by(username: username) || User.find_by(email: username)

    # user not found
    if user.blank?
      render json: { error: "No user with that email or username was fine" }, status: 404
    end

    # user found
    if user.present?
      success = user.check_password(params[:password])
      # password checks out
      if success
        token = user.authenticate!
        render json: { notice: "Successfully logged in", token: token }, status: 200
      else # wrong password
        render json: { error: 'Incorrect password' }, status: 401
      end
    end
  end

end
