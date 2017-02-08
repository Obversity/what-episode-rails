class ApplicationController < ActionController::API

  private

  def authorize!
    token = params[:token]
    @user = User.find_by(token: token)
    if @user.blank? || token.blank?
      render json: { error: 'You are not authorized to do this' }, status: 401
    end
  end

end
