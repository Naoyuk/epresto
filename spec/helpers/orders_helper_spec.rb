# frozen_string_literal: true

require 'rails_helper'

# Specs in this file have access to a helper object that includes
# the OrdersHelper. For example:
#
# describe OrdersHelper do
#   describe "string concat" do
#     it "concats two strings with spaces" do
#       expect(helper.concat_strings("this","that")).to eq("this that")
#     end
#   end
# end
RSpec.describe OrdersHelper, type: :helper do
  describe 'tab_link_to' do
    it 'ターゲットのタブ名をリンク文字にしてタブのスタイルを付与したaタグを返す' do
      expect(tab_link_to('/orders', 'All')).to eq "<a class=\"inline-block py-2 px-4 font-semibold rounded-t-lg bg-gray-200 text-grey-light\" href=\"/orders\"><span>All</span></a>"
      expect(tab_link_to('/orders', 'New')).to eq "<a class=\"inline-block py-2 px-4 font-semibold rounded-t-lg bg-gray-200 text-grey-light\" href=\"/orders\"><span>New</span></a>"
    end
  end
end
