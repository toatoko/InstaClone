class Report < ApplicationRecord
  belongs_to :reporter, class_name: "User"
  belongs_to :reportable, polymorphic: true

  validates :reason, presence: true
  validates :reporter, presence: true
end
