class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  # adding authentication_keys: [ :login ] for sigin user :login form instead of original :email form of devise
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, authentication_keys: [ :login ]
  attr_writer :login
  has_one_attached :avatar

  validates :username, uniqueness: { case_sensitive: false }
  has_many :posts




  # to use email or username at login page
  def login
    @login || username || email
  end
  # to be able to login with username or email
  # warden_condition is the bag of devise to go and grab the key we want from db(email or username)
  def self.find_for_database_authentication(warden_conditions)
    # making a copy of the the login key to not affect the original value just to be safe
    conditions = warden_conditions.dup
    # getting the key out of the bag to check the value
    login = conditions.delete(:login)
    # checking the value with this line by lowercase
    where(conditions).find_by([ "lower(username) = :value OR lower(email) = :value", { value: login.downcase } ])
  end
end
