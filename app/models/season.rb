class Season < ApplicationRecord

  has_many :episodes, dependent: :destroy
  belongs_to :show

  validates :number, presence: true

  default_scope ->{ order(number: :asc) }

end
