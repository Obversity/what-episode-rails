class Episode < ApplicationRecord

  belongs_to :season, touch: true, required: true
  has_one :show, through: :season
  has_many :questions, dependent: :destroy

  validates :number, presence: true

  default_scope ->{ order(number: :asc) }

end
