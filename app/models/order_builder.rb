# frozen_string_literal: true

class OrderBuilder
  def build_order(params, vendor_id)
    order = Order.find_or_initialize_by(po_number: params['purchaseOrderNumber'])
    order.vendor_id = vendor_id
    order.po_number = params['purchaseOrderNumber']
    order.po_state = params['purchaseOrderState']

    order_detail = params['orderDetails']

    order.po_date = order_detail['purchaseOrderDate']
    order.po_changed_date = order_detail['purchaseOrderChangedDate']
    order.po_state_changed_date = order_detail['purchaseOrderStateChangedDate']
    order.po_type = order_detail['purchaseOrderType']
    order.payment_method = order_detail['paymentMethod']
    order.ship_window = order_detail['shipWindow']

    unless order.ship_to_party_id.nil?
      order.shipto_id = Shipto.find_by(location_code: order.ship_to_party_id)&.id
    end

    unless order.ship_window.nil?
      from_and_to = split_shipping_window(order.ship_window)
      order.ship_window_from = from_and_to[:ship_window_from]
      order.ship_window_to = from_and_to[:ship_window_to]
    end

    # order.delivery_window = calc_delivery_window(order.ship_to_party_id, order.po_date)
    order.deal_code = order_detail['dealCode'] unless order_detail.nil?
    unless order_detail['importDetails'].nil?
      import_detail = order_detail['importDetails']
      order.import_method_of_payment = import_detail['methodOfPayment']
      order.import_international_commercial_terms = import_detail['internationalCommercialTerms']
      order.import_port_of_delivery = import_detail['portOfDelivery']
      order.import_containers = import_detail['importContainers']
      order.import_shipping_instructions = import_detail['shippingInstructions']
    end
    unless order_detail['sellingParty'].nil?
      order.selling_party_id = order_detail['sellingParty']['partyId']
      unless order_detail['sellingParty']['address'].nil?
        address = order_detail['sellingParty']['address']
        input_address(order, 'selling', address)
      end
    end
    unless order_detail['buyingParty'].nil?
      order.buying_party_id = order_detail['buyingParty']['partyId']
      unless order_detail['buyingParty']['address'].nil?
        address = order_detail['buyingParty']['address']
        input_address(order, 'buying', address)
      end
    end
    unless order_detail['shipToParty'].nil?
      order.ship_to_party_id = order_detail['shipToParty']['partyId']
      unless order_detail['shipToParty']['address'].nil?
        address = order_detail['shipToParty']['address']
        input_address(order, 'ship_to', address)
      end
    end
    unless order_detail['billToParty'].nil?
      order.bill_to_party_id = order_detail['billToParty']['partyId']
      unless order_detail['billToParty']['address'].nil?
        address = order_detail['billToParty']['address']
        input_address(order, 'bill_to', address)
      end
    end
    unless order_detail['taxInfo'].nil?
      order.buying_tax_type = order_detail['taxInfo']['taxType']
      order.buying_tax_number = order_detail['taxInfo']['taxRegistrationNumber']
    end

    order
  end


  def build_order_item(params)
      # order_detail['items'].each do |item|
    order_item = OrderItem.find_or_initialize_by(
      order_id: odr.id,
      amazon_product_identifier: params['amazonProductIdentifier']
    )
    # itm.order_id = order_id
    order_item.item_seq_number = params['itemSequenceNumber']
    order_item.amazon_product_identifier = params['amazonProductIdentifier']
    order_item.vendor_product_identifier = params['vendorProductIdentifier']
    order_item.ordered_quantity_amount = params['orderedQuantity']['amount']
    order_item.ordered_quantity_unit_of_measure = params['orderedQuantity']['unitOfMeasure']
    order_item.ordered_quantity_unit_size = params['orderedQuantity']['unitSize']
    order_item.back_order_allowed = params['isBackOrderAllowed']
    order_item.netcost_amount = params['netCost']['amount'] unless params['netCost'].nil?
    order_item.netcost_currency_code = params['netCost']['currencyCode'] unless params['netCost'].nil?
    order_item.listprice_amount = params['listPrice']['amount'] unless params['listPrice'].nil?
    order_item.listprice_currency_code = params['listPrice']['currencyCode'] unless params['listPrice'].nil?
    order_item.convert_case_quantity

    order_item
  end

  # TODO: これもbuild_acknowledgementに修正する(order_builderみたいに)
  def create_acknowledgement(order, item)
    ack = item.acks.build
    ack.acknowledged_quantity_amount = item.ordered_quantity_amount
    ack.acknowledged_quantity_unit_of_measure = item.ordered_quantity_unit_of_measure
    ack.acknowledged_quantity_unit_size = item.ordered_quantity_unit_size
    ack.scheduled_ship_date = order.ship_window_to
    ack.scheduled_delivery_date = calc_scheduled_delivery_date(order.shipto.province, order.ship_window_to)

    if item.item&.Current?
      ack.acknowledgement_code = 'Accepted'
      # TODO: Phase2以降の実装内容。Price違いの警告
      # unless item.listprice_amount == item.item.price
      #   @notice_title ||= 'Prices for the following items differ from Item Master prices.'
      #   price_diff_items << "\nASIN: #{item.amazon_product_identifier}, PO Price: #{item.listprice_amount}, Item Master Price: #{item.item.price}"
      # end
    else
      ack.acknowledgement_code = 'Rejected'
    end

    if item.item.nil?
      ack.rejection_reason = 'InvalidProductIdentifier'
    elsif item.item.Discontinued?
      ack.rejection_reason = 'ObsoleteProduct'
      # elsif item.item.price != item.listprice_amount
      #   # TODO: Phase2以降でこの条件は実装予定
      #   ack.rejection_reason = 'TemporarilyUnavailable'
    end
    ack.save

    # TODO: 以下はPhase2以降で実装予定
    # if # 在庫がオーダー数よりも少なかった場合
    #   # 配列itemAcknowledgementを1個追加
    #   acknowledge_additional = acknowledge_detail
    #   acknowledged_additional_quantity = {}
    #   if item.item.Current? && (item.listprice_amount == item.item.price)
    #     acknowledge_additional['acknowledgementCode'] = 'Accepted'
    #   elsif # バックオーダーの条件
    #     acknowledge_additional['acknowledgementCode'] = 'Backordered'
    #     acknowledge_additional['rejectionReason'] = 'TemporarilyUnavailable'
    #   else
    #     # ディスコンの場合
    #     acknowledge_additional['acknowledgementCode'] = 'Rejected'
    #     acknowledge_additional['rejectionReason'] = 'ObsoleteProduct'
    #   end
    #   acknowledged_additional_quantity['amount'] = item.ordered_quantity_amount -
    #   acknowledged_additional_quantity['unitOfMeasure'] = item.acks.acknowledged_quantity_unit_of_measure
    #   acknowledged_additional_quantity['unitSize'] = item.acks.acknowledged_quantity_unit_size
    #   acknowledge_additional['acknowledgedQuantity'] = acknowledged_additional_quantity

    #   item_acknowledgements << acknowledge_additional
    # end
  end

  private

  def split_shipping_window(window)
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

  def calc_scheduled_delivery_date(province, ship_window_to)
    if province == 'BC'
      # Shipping within B.C. = 3 days
      (ship_window_to + 3 * 24 * 60 * 60).to_fs(:iso8601)
    elsif province == 'AB'
      # Calgary = 1 week
      (ship_window_to + 7 * 24 * 60 * 60).to_fs(:iso8601)
    elsif province == 'ON'
      # Ontario = 3 weeks
      (ship_window_to + 21 * 24 * 60 * 60).to_fs(:iso8601)
    else
      # Not given any information
    end
  end

  def input_address(order, prefix, address)
    order.send("#{prefix}_address_name=", address['name'])
    order.send("#{prefix}_address_line1=", address['addressLine1'])
    order.send("#{prefix}_address_line2=", address['addressLine2'])
    order.send("#{prefix}_address_line3=", address['addressLine3'])
    order.send("#{prefix}_address_city=", address['city'])
    order.send("#{prefix}_address_district=", address['district'])
    order.send("#{prefix}_address_state_or_region=", address['state_or_region'])
    order.send("#{prefix}_address_postal_code=", address['postal_code'])
    order.send("#{prefix}_address_country_code=", address['country_code'])
    order.send("#{prefix}_address_phone=", address['phone'])
  end
end
