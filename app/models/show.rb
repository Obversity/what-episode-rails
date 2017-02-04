class Show < ApplicationRecord
  include PgSearch

  has_many :seasons
  has_many :episodes, through: :seasons
  has_many :questions, through: :episodes

  validates :title, presence: true

  pg_search_scope :search, against: [:title]

end
