class Post < ApplicationRecord
  belongs_to :user
  before_create :set_active
  scope :active, -> { where active: true }
  has_one_attached :image
  has_many :comments, dependent: :destroy
  has_many :likes, dependent: :destroy
  validates :image, presence: true

  def set_active
    self.active = true
  end
  def liked_by?(user)
    return false unless user
    likes.exists?(user: user)
  end

  def saved_by?(user)
    return false unless user
    saved_posts.exists?(user: user)
  end
end
