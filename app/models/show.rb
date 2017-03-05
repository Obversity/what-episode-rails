class Show < ApplicationRecord
  include PgSearch
  include CacheMethod

  has_many :seasons, dependent: :destroy
  has_many :episodes, through: :seasons
  has_many :questions, through: :episodes

  validates :title, presence: true

  pg_search_scope :search, against: [:title]

  cache_method :as_json, expires_in: 10.minutes

end
