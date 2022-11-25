module Support
  module SpApiHelpers
    def stub_request_access_token
      stub_request(:post, "https://api.amazon.com/auth/o2/token")
        .with(body: "grant_type=refresh_token&refresh_token=a-refresh-token&client_id=a-client-id&client_secret=a-client-secret",
              headers: { "Content-Type" => "application/x-www-form-urlencoded;charset=UTF-8", "Expect" => "",
                         "User-Agent" => "" })
        .to_return(status: 200, body: '{ "access_token": "this_will_get_you_into_drury_lane", "expires_in": 3600 }', headers: {})
    end

    def stub_get_purchase_orders
      stub_request(:get, "https://#{hostname}/vendor/orders/v1/purchaseOrders?MarketplaceIds=#{marketplace_ids}")
        .to_return(status: 200, body: File.read("./spec/support/get_purchase_orders.json"), headers: {})
    end

    def hostname
      "sellingpartnerapi-na.amazon.com"
    end
  end
end
