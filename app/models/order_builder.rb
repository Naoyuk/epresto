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
        from_and_to = split_shipping_window(odr.ship_window)
        odr.ship_window_from = from_and_to[:ship_window_from]
        odr.ship_window_to = from_and_to[:ship_window_to]
      end

      # odr.delivery_window = calc_delivery_window(odr.ship_to_party_id, odr.po_date)
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
