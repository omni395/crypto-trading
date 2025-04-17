# frozen_string_literal: true

class CoinCardComponent < ViewComponent::Base
  def initialize(coin:)
    @coin = coin
  end
end
