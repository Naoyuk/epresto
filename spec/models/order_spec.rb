# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Order, type: :model do
  it 'has a valid factory' do
    expect(build(:order)).to be_valid
  end
end
