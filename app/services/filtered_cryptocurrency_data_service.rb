# Service for fetching and filtering cryptocurrency data for a given set of pairs
class FilteredCryptocurrencyDataService
  # filters: hash with keys :min_volume, :min_deals, :change, :price_above, :price_below, etc.
  def initialize(pairs, filters = {})
    @pairs = pairs
    @filters = filters
  end

  def call
    scope = Cryptocurrency.where(symbol: @pairs)
    scope = scope.where('volume >= ?', @filters[:min_volume]) if @filters[:min_volume].present?
    scope = scope.where('trades >= ?', @filters[:min_deals]) if @filters[:min_deals].present?
    scope = scope.where('price_change_percent >= ?', @filters[:change]) if @filters[:change].present?
    scope = scope.where('last_price >= ?', @filters[:price_above]) if @filters[:price_above].present?
    scope = scope.where('last_price <= ?', @filters[:price_below]) if @filters[:price_below].present?
    scope
  end
end
