# frozen_string_literal: true

class DemoComponent < ApplicationComponent
  def initialize(shorten: false)
    super
    @shorten = shorten
  end

  def message
    if @shorten
      t('.short_message')
    else
      t('.message')
    end
  end
end
