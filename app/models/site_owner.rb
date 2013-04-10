class SiteOwner
  include MongoMapper::Document
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :confirmable

  key :username, String

  ## Database authenticatable
  key :email, String, :null => false, :default => ""
  key :encrypted_password, String, :null => false, :default => ""

  ## Recoverable
  key :reset_password_token,    String
  key :reset_password_sent_at,  Time

  ## Rememberable
  key :remember_created_at,  Time

  ## Trackable
  key :sign_in_count, Integer, :default => 0
  key :current_sign_in_at, Time
  key :last_sign_in_at,     Time
  key :current_sign_in_ip,  String
  key :last_sign_in_ip,     String

  ## Confirmable
  key :confirmation_token, String
  key :confirmed_at, Time
  key :confirmation_sent_at, Time
  key :unconfirmed_email, String

  ## Token authenticatable
  key :authentication_token, String

  timestamps!

  many :shops

end
