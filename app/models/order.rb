# frozen_string_literal: true

class Order < ApplicationRecord
  belongs_to :vendor
  has_many :order_items

  # Class methods
  def self.api_credentials
    @aws_access_key = Rails.application.credentials[:AWS_ACCESS_KEY_ID]
    @aws_secret_key = Rails.application.credentials[:AWS_SECRET_ACCESS_KEY]
    @iam_access_key_id = Rails.application.credentials[:IAM_ACCESS_KEY]
    @iam_secret_access_key = Rails.application.credentials[:IAM_SECRET_ACCESS_KEY]
    @refresh_token = Rails.application.credentials[:DEV_CENTRAL_REFRESH_TOKEN]
    @access_token = Order.generate_access_token
  end

  def self.generate_access_token
    url = URI('https://api.amazon.com/auth/o2/token')

    https = Net::HTTP.new(url.host, url.port)
    https.use_ssl = true

    request = Net::HTTP::Post.new(url)
    request['Content-Type'] = 'application/x-www-form-urlencoded'
    request.body =
      "grant_type=refresh_token&"\
      "refresh_token=#{@refresh_token}&"\
      "client_id=#{@aws_access_key}&"\
      "client_secret=#{@aws_secret_key}"

    response = https.request(request)
    JSON.parse(response.body)['access_token']
  end

  def self.import_po(vendor_id, created_after, created_before)
    # AmazonからPOを取得
    get_pos_params = {api: 'pos', path: '/vendor/orders/v1/purchaseOrders', created_after:, created_before:}
    pos = Order.fetch_original_po(get_pos_params)
    # なんらかのエラーでPOを取得できなかったらエラーコードをviewに渡して終了
    return pos if pos.has_key?('errors')

    # posからOrdersとOrderItemsにレコードを作成していく
    pos['payload']['orders'].each do |order|
      # Ordersの作成
      odr = Order.find_or_initialize_by(po_number: order['purchaseOrderNumber'])
      odr.vendor_id = vendor_id
      odr.po_number = order['purchaseOrderNumber']
      odr.po_state = order['purchaseOrderState']
      odr.po_date = order['orderDetails']['purchaseOrderDate']
      odr.po_changed_date = order['orderDetails']['purchaseOrderChangedDate']
      odr.po_state_changed_date = order['orderDetails']['purchaseOrderStateChangedDate']
      odr.po_type = order['orderDetails']['purchaseOrderType']
      odr.payment_method = order['orderDetails']['paymentMethod']
      odr.buying_party_id = order['orderDetails']['buyingParty']['partyId']
      odr.selling_party_id = order['orderDetails']['sellingParty']['partyId']
      odr.ship_to_party_id = order['orderDetails']['shipToParty']['partyId']
      odr.bill_to_party_id = order['orderDetails']['billToParty']['partyId']
      odr.delivery_window = order['shipWindow']
      odr.deal_code = order['orderDetails']['dealCode'] unless order['orderDetails'].nil?
      unless order['orderDetails']['importDetails'].nil?
        odr.import_method_of_payment = order['orderDetails']['importDetails']['methodOfPayment']
        odr.import_international_commercial_terms =
          order['orderDetails']['importDetails']['internationalCommercialTerms']
        odr.import_port_of_delivery = order['orderDetails']['importDetails']['portOfDelivery']
        odr.import_containers = order['orderDetails']['importDetails']['importContainers']
        odr.import_shipping_instructions = order['orderDetails']['importDetails']['shippingInstructions']
      end
      unless order['orderDetails']['buyingParty'].nil?
        unless order['orderDetails']['buyingParty']['address'].nil?
          odr.buying_address_name = order['orderDetails']['buyingParty']['address']['name']
          odr.buying_address_line1 = order['orderDetails']['buyingParty']['address']['addressLine1']
          odr.buying_address_city = order['orderDetails']['buyingParty']['address']['city']
          odr.buying_address_state_or_region = order['orderDetails']['buyingParty']['address']['stateOrRegion']
          odr.buying_address_postal_code = order['orderDetails']['buyingParty']['address']['postalCode']
          odr.buying_address_country_code = order['orderDetails']['buyingParty']['address']['countryCode']
          odr.buying_address_phone = order['orderDetails']['buyingParty']['address']['phone']
        end
      end
      unless order['orderDetails']['shipToParty'].nil?
        unless order['orderDetails']['shipToParty']['address'].nil?
          odr.ship_to_address_name = order['orderDetails']['shipToParty']['address']['name']
          odr.ship_to_address_line1 = order['orderDetails']['shipToParty']['address']['addressLine1']
          odr.ship_to_address_city = order['orderDetails']['shipToParty']['address']['city']
          odr.ship_to_address_state_or_region = order['orderDetails']['shipToParty']['address']['stateOrRegion']
          odr.ship_to_address_postal_code = order['orderDetails']['shipToParty']['address']['postalCode']
          odr.ship_to_address_country_code = order['orderDetails']['shipToParty']['address']['countryCode']
          odr.ship_to_address_phone = order['orderDetails']['shipToParty']['address']['phone']
        end
      end
      unless order['orderDetails']['billToParty'].nil?
        unless order['orderDetails']['shipToParty']['address'].nil?
          odr.bill_to_address_name = order['orderDetails']['billToParty']['address']['name']
          odr.bill_to_address_line1 = order['orderDetails']['billToParty']['address']['addressLine1']
          odr.bill_to_address_city = order['orderDetails']['billToParty']['address']['city']
          odr.bill_to_address_state_or_region = order['orderDetails']['billToParty']['address']['stateOrRegion']
          odr.bill_to_address_postal_code = order['orderDetails']['billToParty']['address']['postalCode']
          odr.bill_to_address_country_code = order['orderDetails']['billToParty']['address']['countryCode']
          odr.bill_to_address_phone = order['orderDetails']['billToParty']['address']['phone']
        end
      end
      unless order['orderDetails']['taxInfo'].nil?
        odr.tax_type = order['orderDetails']['taxInfo']['taxType']
        odr.tax_registration_number = order['orderDetails']['taxInfo']['taxRegistrationNumber']
      end

      odr.save

      # OrderItemsの作成
      order['orderDetails']['items'].each do |item|
        itm = OrderItem.find_or_initialize_by(
          order_id: odr.id,
          amazon_product_identifier: item['amazonProductIdentifier']
        )
        # itm.order_id = order_id
        itm.item_seq_number = item['itemSequenceNumber']
        itm.amazon_product_identifier = item['amazonProductIdentifier']
        itm.vendor_product_identifier = item['vendorProductIdentifier']
        itm.ordered_quantity_amount = item['orderedQuantity']['amount']
        itm.ordered_quantity_unit_of_measure = item['orderedQuantity']['unitOfMeasure']
        itm.ordered_quantity_unit_size = item['orderedQuantity']['unitSize']
        itm.back_order_allowed = item['isBackOrderAllowed']
        itm.netcost_amount = item['netCost']['amount'] unless item['netCost'].nil?
        itm.netcost_currency_code = item['netCost']['currencyCode'] unless item['netCost'].nil?
        itm.listprice_amount = item['listPrice']['amount'] unless item['listPrice'].nil?
        itm.listprice_currency_code = item['listPrice']['currencyCode'] unless item['listPrice'].nil?

        itm.save
      end
    end
    Order.all
  end

  def self.fetch_original_po(params)
    url_and_signature = Order.generate_url_and_sign(params)
    @url = url_and_signature[:url]
    @signature = url_and_signature[:signature]

    @req = Net::HTTP::Get.new(@url)
    Order.http_header

    Order.send_http_request
  end

  def self.acknowledge(po_number)
    # order_id = Order.find_by(po_number: po_number).id
    # item_codes = OrderItem.where(order_id: order_id)
    # items = {}
    # item_codes.each do |item|
    #   
    # end
    if Rails.env.development? || Rails.env.test?
      params = {api: 'acknowledgement', path: '/vendor/orders/v1/acknowledgements'}
    else
      params = {api: 'acknowledgement', path: '/vendor/orders/v1/acknowledgements', po_number:, selling_party:, items:}
    end
    url_and_signature = Order.generate_url_and_sign(params)
    @url = url_and_signature[:url]
    @signature = url_and_signature[:signature]
    body_values = url_and_signature[:body_values]

    @req = Net::HTTP::Post.new(@url)
    @req["Content-Type"] = "application/json"
    @req.body = JSON.dump(body_values)
    Order.http_header

    Order.send_http_request
  end

  require 'uri'
  require 'net/http'

  module Net::HTTPHeader
    def capitalize(name)
      name
    end
    private :capitalize
  end

  def self.generate_url_and_sign(params)
    # POs: params include :api, :path
    # Acknowledgement: params include :api, :po_number, :selling_party, :items

    if (Rails.env.development? || Rails.env.test?)
      host = 'sandbox.sellingpartnerapi-na.amazon.com'
    else
      host = 'sellingpartnerapi-na.amazon.com'
    end
    service = 'execute-api'
    region = 'us-east-1'
    endpoint = "https://#{host}"
    path = params[:path]
    if params[:api] == 'pos'
      if (Rails.env.development? || Rails.env.test?)
        start_date = '2019-08-20T14:00:00'.gsub(':', '%3A')
        end_date = '2019-09-21T00:00:00'.gsub(':', '%3A')
        limit = 1
      else
        start_date = (created_after.to_date - 24 * 60 * 60 * 7).strftime('%Y-%m-%dT%H:%M:%S').gsub(':', '%3A')
        end_date = created_before.to_date.strftime('%Y-%m-%dT%H:%M:%S').gsub(':', '%3A')
        limit = 54
      end
      method = 'GET'
      @query_hash = {
        'limit' => limit,
        'createdAfter' => start_date,
        'createdBefor' => end_date,
        'sortOrder' => 'DESC'
      }
      query = Order.formatted_query
      url = URI("#{endpoint}#{path}?#{query}")
    elsif params[:api] == 'acknowledgement'
      if (Rails.env.development? || Rails.env.test?)
        path = '/vendor/orders/v1/acknowledgements'
        acknowledgement_date = '2021-03-12T17:35:26.308Z'.gsub(':', '%3A')
        body_values = {
          "acknowledgements": [
            {
              "purchaseOrderNumber": "TestOrder202",
              "sellingParty": {
                "partyId": "API01"
              },
              "acknowledgementDate": "2021-03-12T17:35:26.308Z",
              "items": [
                {
                  "vendorProductIdentifier": "028877454078",
                  "orderedQuantity": {
                    "amount": 10
                  },
                  "netCost": {
                    "amount": "10.2"
                  },
                  "itemAcknowledgements": [
                    {
                      "acknowledgementCode": "Accepted",
                      "acknowledgedQuantity": {
                        "amount": 10
                      }
                    }
                  ]
                }
              ]
            }
          ]
        }
      else
        po_number = params[:po_number]
        selling_party = params[:selling_party]
        acknowledgement_date = Time.now.strftime('%Y-%m-%dT%H:%M:%S').gsub(':', '%3A')
        items = params[:items]
      end
      method = 'POST'
      url = URI("#{endpoint}#{path}")
    end
    Order.api_credentials

    signer = Aws::Sigv4::Signer.new(
      service: service,
      region: region,
      access_key_id: @iam_access_key_id,
      secret_access_key: @iam_secret_access_key
    )

    if params[:api] == 'pos'
      signature = signer.sign_request(
        http_method: method,
        url: url
      )
    elsif params[:api] == 'acknowledgement'
      signature = signer.sign_request(
        http_method: method,
        url: url,
        body: JSON.dump(body_values)
      )
    end

    {url:, signature:, body_values:}
  end

  def self.http_header
    @req['host'] = @signature.headers['host']
    @req['x-amz-access-token'] = @access_token
    @req['user-agent'] = 'ePresto Connection1/1.0 (Language=Ruby/3.1.2)'
    @req['x-amz-date'] = @signature.headers['x-amz-date']
    @req['x-amz-content-sha256'] = @signature.headers['x-amz-content-sha256']
    @req['Authorization'] = @signature.headers['authorization']
  end

  def self.send_http_request
    https = Net::HTTP.new(@url.host, @url.port)
    https.use_ssl = true

    res = https.request(@req)
    JSON.parse(res.body)
  end

  def self.formatted_query
    list = []
    @query_hash.each_pair do |k, v|
      k = k.downcase
      list << [k, v]
    end

    list.sort.map do |k, v|
      "#{k}=#{v}"
    end.join('&')
  end
end
