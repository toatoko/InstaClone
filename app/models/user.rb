class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  # adding authentication_keys: [ :login ] for sigin user :login form instead of original :email form of devise
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, authentication_keys: [ :login ]
  attr_writer :login
  has_one_attached :avatar
  validates :username, uniqueness: { case_sensitive: false }
  validates :avatar, presence: true

  has_many :posts, dependent: :destroy
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

  # Message associations
  has_many :sent_messages, class_name: "Message", foreign_key: "sender_id", dependent: :destroy
  has_many :received_messages, class_name: "Message", foreign_key: "receiver_id", dependent: :destroy
  # Report associations
  has_many :reports_about_me, as: :reportable, class_name: "Report", dependent: :destroy
  has_many :submitted_reports, class_name: "Report", foreign_key: "reporter_id", dependent: :destroy
  has_many :resolved_reports, class_name: "Report", foreign_key: "resolved_by_id", dependent: :nullify
  scope :all_except, ->(user) { where.not(id: user.id) }

  def admin?
    admin == true
  end
  # Method to make a user admin
  def make_admin!
    update!(admin: true)
  end

  # Method to remove admin privileges
  def remove_admin!
    update!(admin: false)
  end
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
    # Use counter cache if available, otherwise fall back to count
    if has_attribute?(:posts_count)
      read_attribute(:posts_count) || 0
    else
      posts.count
    end
  end

  def followers_count
    # Use counter cache if available, otherwise fall back to count
    if has_attribute?(:followers_count)
      read_attribute(:followers_count) || 0
    else
      followers.count
    end
  end

  def following_count
    # Use counter cache if available, otherwise fall back to count
    if has_attribute?(:following_count)
      read_attribute(:following_count) || 0
    else
      following.count
    end
  end

  def to_param
    username
  end

  # Message-related methods
  def conversations
    # Get all users this user has had conversations with
    sent_to_ids = sent_messages.distinct.pluck(:receiver_id)
    received_from_ids = received_messages.distinct.pluck(:sender_id)
    user_ids = (sent_to_ids + received_from_ids).uniq

    User.where(id: user_ids)
  end

  def conversation_with(other_user)
    Message.between_users(self, other_user)
  end

  def unread_messages_count
    received_messages.unread.count
  end

  def unread_messages_from(other_user)
    received_messages.where(sender: other_user).unread.count
  end

  def last_message_with(other_user)
    conversation_with(other_user).last
  end
end
