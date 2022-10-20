# frozen_string_literal: true

class Vendor < ApplicationRecord
  validates :name, presence: true
end
