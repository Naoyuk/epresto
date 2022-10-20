# frozen_string_literal: true

class Vendor < ApplicationRecord
  validates :name, presence: true

  has_many :users
  has_many :items
end
