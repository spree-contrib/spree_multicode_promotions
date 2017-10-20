Spree::Promotion::Actions::FreeShipping.class_eval do
  def perform(payload = {})
    order = payload[:order]
    promotion_code = payload[:promotion_code]
    create_unique_adjustments(order, order.shipments, promotion_code)
  end
end
