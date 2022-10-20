# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'ImportItems', type: :system do
  before do
    driven_by(:rack_test)
  end

  scenario 'A user log in and import and update item master' do
    item1 = create(:item)
    item2 = create(:item)
  end
end
