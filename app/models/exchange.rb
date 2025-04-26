class Exchange < ApplicationRecord
  validates :name, :slug, :api_url, :market_type, :status, presence: true
  validates :slug, uniqueness: true

  scope :active, -> { where(status: 'active') }
end
