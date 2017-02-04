class Question < ApplicationRecord
  has_one :show, through: :episode
  belongs_to :episode

  validates :episode, :event, presence: true
end
