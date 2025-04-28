require 'devise'

class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :omniauthable, omniauth_providers: [:google_oauth2]

  has_many :user_roles
  has_many :roles, through: :user_roles

  def has_role?(role_name)
    roles.exists?(name: role_name)
  end

  DEFAULT_SETTINGS = {
    "default_volume" => "300000",
    "default_deals" => "100000",
    "default_change" => "2",
    "default_price_above" => "0.01",
    "default_price_below" => "5",
    "default_basecoin" => "USDT",
    "default_exchange" => "Binance Spot",
    "default_quote_asset" => "USDT",
    "default_status" => "trading"
  }.freeze

  def self.from_omniauth(auth)
    where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
      user.email = auth.info.email
      user.password = Devise.friendly_token[0, 20]
      user.provider = auth.provider
      user.uid = auth.uid
    end
  end

  def settings_with_defaults
    settings_hash = self.settings.is_a?(Hash) ? self.settings : (self.settings.present? ? JSON.parse(self.settings) : {})
    DEFAULT_SETTINGS.merge(settings_hash)
  end
end
