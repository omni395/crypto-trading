class Exchange < ApplicationRecord
  validates :name, :slug, :api_url, :status, presence: true
  validates :slug, uniqueness: true
  validates :websocket_url, format: { with: URI::DEFAULT_PARSER.make_regexp(%w[wss ws]), message: "должен быть валидным WebSocket URL" }, allow_blank: true

  scope :active, -> { where(status: 'active') }
end
