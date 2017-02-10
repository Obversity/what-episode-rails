class ApplicationController < ActionController::API

  private

  def authorize!
    # get <token> from { 'Authorization' => 'Bearer <token>'}
    token = request.headers['Authorization'].try(:split, ' ').try(:second)
    @user = token.present? ? User.find_by(token: token) : nil
    if @user.blank? || token.blank?
      render json: { error: 'You are not authorized to do this' }, status: 401
    end
  end

end
