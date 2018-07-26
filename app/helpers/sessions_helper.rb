module SessionsHelper

  # 認証フィルター
  def authenticate
    unless logged_in?()
      render json: { messages: ['not login'] }, status: :unauthorized
    end
  end

  def check_unauthenticated
    if logged_in?()
      render json: { messages: ['already logged in'] }, status: :bad_request
    end
  end

  # Admin認可フィルター
  def authorize_for_admin
    unless current_user()&.admin?()
      render json: { messages: ['not allowed'] }, status: :forbidden
    end
  end

  # トークンに対応するユーザーを返す（CQSでないメソッド）
  # キャッシュされるため、返されるユーザーがDirtyになり得るので使用の際は注意すること
  def current_user
    return @current_user if @current_user
    return nil unless request.headers['Authorization']

    decoded_token =
      begin
        decode_jwt_token()
      rescue JWT::DecodeError
        return nil
      rescue JWT::ExpiredSignature
        # Handle expired token, e.g. logout user or deny access
        return nil
      end

    @current_user = User.find_by(id: decoded_token[0]['user_id'])
  end

  # カレントユーザーのキャッシュを更新してから返す（CQSでないメソッド）
  def nondirty_current_user()
    @current_user = User.find_by(id: current_user()&.id)
  end

  # ユーザーがログインしていればtrue、その他ならfalseを返す
  def logged_in?
    !current_user().nil?()
  end

  # 渡されたユーザーがログイン済みユーザーであればtrueを返す
  def current_user?(user)
    user == current_user()
  end

  def generate_jwt(user)
    hmac_secret = Rails.application.secrets.secret_key_base
    expiration_time = Time.now().to_i() + (60 * 60 * 24 * 365 * 20)
    # roleは含めないことにした（ロールが変更されたときにtokenのroleと一致しなくなると考えたから）
    payload = { user_id: user.id, exp: expiration_time }

    JWT.encode(payload, hmac_secret, 'HS256')
  end
  
  def decode_jwt_token
    scheme, token = request.headers['Authorization'].split(' ')
    jwt_bearer_token = scheme == 'Bearer' ? token : nil
    hmac_secret = Rails.application.secrets.secret_key_base

    JWT.decode(jwt_bearer_token, hmac_secret, true, { algorithm: 'HS256' })    
  end

  def logout
    @current_user = nil
  end
end