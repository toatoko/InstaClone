class Post < ApplicationRecord
  belongs_to :user
  before_create :set_active
  scope :active, -> { where active: true }
  has_one_attached :image

  def set_active
    self.active = true
  end
end
