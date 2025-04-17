# frozen_string_literal: true

class InstrumentComponent < ViewComponent::Base
  def initialize(coin:)
    @coin = coin
  end
end
