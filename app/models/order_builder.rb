# frozen_string_literal: true

class OrderBuilder
  def create_order_and_order_items(params)
    po_numbers = []
    errors = []
    params[:purchase_orders]['payload']['orders'].each do |order|
      # Ordersの作成
      odr = Order.find_or_initialize_by(po_number: order['purchaseOrderNumber'])
      odr.vendor_id = params[:vendor_id]
      odr.po_number = order['purchaseOrderNumber']
      odr.po_state = order['purchaseOrderState']
      order_detail = order['orderDetails']
      odr.po_date = order_detail['purchaseOrderDate']
      odr.po_changed_date = order_detail['purchaseOrderChangedDate']
      odr.po_state_changed_date = order_detail['purchaseOrderStateChangedDate']
      odr.po_type = order_detail['purchaseOrderType']
      odr.payment_method = order_detail['paymentMethod']
      odr.buying_party_id = order_detail['buyingParty']['partyId']
      odr.selling_party_id = order_detail['sellingParty']['partyId']
      odr.ship_to_party_id = order_detail['shipToParty']['partyId']
      odr.bill_to_party_id = order_detail['billToParty']['partyId']
      odr.ship_window = order_detail['shipWindow']

      unless odr.ship_to_party_id.nil?
        odr.shipto_id = Shipto.find_by(location_code: odr.ship_to_party_id)&.id
      end

      unless odr.ship_window.nil?
        from_and_to = split_shippin_window(odr.ship_window)
        odr.ship_window_from = from_and_to[:ship_window_from]
        odr.ship_window_to = from_and_to[:ship_window_to]
      end

      odr.delivery_window = calc_delivery_window(odr.ship_to_party_id, odr.po_date)
      odr.deal_code = order_detail['dealCode'] unless order_detail.nil?
      unless order_detail['importDetails'].nil?
        import_detail = order_detail['importDetails']
        odr.import_method_of_payment = import_detail['methodOfPayment']
        odr.import_international_commercial_terms = import_detail['internationalCommercialTerms']
        odr.import_port_of_delivery = import_detail['portOfDelivery']
        odr.import_containers = import_detail['importContainers']
        odr.import_shipping_instructions = import_detail['shippingInstructions']
      end
      unless order_detail['sellingParty'].nil?
        unless order_detail['sellingParty']['address'].nil?
          address = order_detail['sellingParty']['address']
          input_address(odr, 'selling', address)
        end
      end
      unless order_detail['buyingParty'].nil?
        unless order_detail['buyingParty']['address'].nil?
          address = order_detail['buyingParty']['address']
          input_address(odr, 'buying', address)
        end
      end
      unless order_detail['shipToParty'].nil?
        unless order_detail['shipToParty']['address'].nil?
          address = order_detail['shipToParty']['address']
          input_address(odr, 'ship_to', address)
        end
      end
      unless order_detail['billToParty'].nil?
        unless order_detail['billToParty']['address'].nil?
          address = order_detail['billToParty']['address']
          input_address(odr, 'bill_to', address)
        end
      end
      unless order_detail['taxInfo'].nil?
        odr.buying_tax_type = order_detail['taxInfo']['taxType']
        odr.buying_tax_number = order_detail['taxInfo']['taxRegistrationNumber']
      end

      if odr.valid?
        odr.save
        po_numbers << odr.po_number
      else
        error = {
          code: '010',
          desc: 'Import Purchase Order Error',
          messages: odr.errors.full_messages
        }
        errors << error
      end

      # OrderItemsの作成
      order_detail['items'].each do |item|
        itm = OrderItem.find_or_initialize_by(
          order_id: odr.id,
          amazon_product_identifier: item['amazonProductIdentifier']
        )
        # itm.order_id = order_id
        # itm.item_id = Item.find_by(asin: item['amazonProductIdentifier'])&.id
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

        if itm.valid?
          itm.save
          itm.convert_case_quantity
        else
          error = {
            code: '020',
            desc: 'Import Order Item Error',
            messages: itm.errors.full_messages
          }
          errors << error
        end
      end
    end

    # 取得したPOのPurchaseOrderNumberの配列を返す
    { po_numbers:, errors: }
  end

  private

  def split_shippin_window(window)
    pos_of_div = window.index('--')
    from = window.slice(0, pos_of_div)
    to = window.slice(pos_of_div + 2, 20)
    ship_window_from = DateTime.new(
      from.slice(0, 4).to_i, from.slice(5, 2).to_i, from.slice(8, 2).to_i,
      from.slice(11, 2).to_i, from.slice(14, 2).to_i, from.slice(17, 2).to_i
    )
    ship_window_to = DateTime.new(
      to.slice(0, 4).to_i, to.slice(5, 2).to_i, to.slice(8, 2).to_i,
      to.slice(11, 2).to_i, to.slice(14, 2).to_i, to.slice(17, 2).to_i
    )

    { ship_window_from:, ship_window_to: }
  end

  def calc_delivery_window(ship_to_id, _ordered_date)
    shipto = Shipto.find_by(location_code: ship_to_id)
    province = shipto&.province
    if province == 'BC'
      (Time.now + 3 * 24 * 60 * 60).to_fs(:dat)
    elsif province == 'AB'
      (Time.now + 7 * 24 * 60 * 60).to_fs(:dat)
    elsif province == 'ON'
      (Time.now + 21 * 24 * 60 * 60).to_fs(:dat)
    else
      # Not given any information
    end
  end

  def input_address(odr, prefix, address)
    odr.send("#{prefix}_address_name=", address['name'])
    odr.send("#{prefix}_address_line1=", address['addressLine1'])
    odr.send("#{prefix}_address_line2=", address['addressLine2'])
    odr.send("#{prefix}_address_line3=", address['addressLine3'])
    odr.send("#{prefix}_address_city=", address['city'])
    odr.send("#{prefix}_address_district=", address['district'])
    odr.send("#{prefix}_address_state_or_region=", address['state_or_region'])
    odr.send("#{prefix}_address_postal_code=", address['postal_code'])
    odr.send("#{prefix}_address_country_code=", address['country_code'])
    odr.send("#{prefix}_address_phone=", address['phone'])
  end
end

