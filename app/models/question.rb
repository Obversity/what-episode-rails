class Question < ApplicationRecord

  has_one :show, through: :episode
  belongs_to :episode, touch: true

  validates :episode, :event, presence: true
  validates :event, length: { in: 10..100 }

end
