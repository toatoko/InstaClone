class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  # adding authentication_keys: [ :login ] for sigin user :login form instead of original :email form of devise
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, authentication_keys: [ :login ]
  attr_writer :login
  has_one_attached :avatar
  validates :username, uniqueness: { case_sensitive: false }
  has_many :posts, dependent: :destroy
  has_many :stories, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_many :likes, dependent: :destroy
  has_many :active_relationships, class_name: "Relationship",
                                  foreign_key: "follower_id",
                                  dependent: :destroy
  has_many :passive_relationships, class_name: "Relationship",
                                   foreign_key: "followed_id",
                                   dependent: :destroy
  has_many :following, through: :active_relationships, source: :followed
  has_many :followers, through: :passive_relationships, source: :follower



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
  def follow(other_user)
    following << other_user unless following?(other_user)
  end

  def unfollow(other_user)
    following.delete(other_user)
  end

  def following?(other_user)
    following.include?(other_user)
  end

  def posts_count
    posts.count
  end

  def followers_count
    followers.count
  end

  def following_count
    following.count
  end
end
