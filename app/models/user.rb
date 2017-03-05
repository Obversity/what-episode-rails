class User < ApplicationRecord

  has_and_belongs_to_many :shows

  validates :password, :salt, presence: true
  validates :username, presence: true, if: ->{ email.blank? }
  validates :email, presence: true, if: ->{ username.blank? }

  validates_uniqueness_of :email
  validates_uniqueness_of :username

  def check_password(pwd)
    self.password == hash_password(pwd)
  end

  # override setter to hash the password
  def password=(pwd)
    self.salt = SecureRandom.hex(8)
    super(hash_password(pwd))
  end

  def authenticate!
    token = SecureRandom.hex(16)
    update(token: token, last_signed_in: DateTime.now)
    return token
  end

  private

  def hash_password(password, salt = self.salt)
    Digest::SHA512.hexdigest password + salt
  end

end
