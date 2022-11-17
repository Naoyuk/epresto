class OrderItemAcknowledgement < ApplicationRecord
  belongs_to :order_item

  # definitions of enum
  enum acknowledgement_code: {
    Accepted: 0,
    Backordered: 1,
    Rejected: 2
  }

  enum rejection_reason: {
    TemporarilyUnavailable: 0,
    InvalidProductIdentifier: 1,
    ObsoleteProduct: 2
  }

  enum acknowledged_quantity_unit_of_measure: {
    Cases: 0,
    Eaches: 1
  }

end
