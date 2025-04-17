# frozen_string_literal: true

class FiltersComponent < ViewComponent::Base
  def initialize(q:)
    @q = q
  end
end
