# frozen_string_literal: true

class InstrumentsComponent < ViewComponent::Base
  def initialize(cryptocurrencies:)
    @cryptocurrencies = cryptocurrencies
    @cryptocurrencies_count = @cryptocurrencies.size
  end
end
