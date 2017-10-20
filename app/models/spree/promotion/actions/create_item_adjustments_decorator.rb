Spree::Promotion::Actions::CreateItemAdjustments.class_eval do
  def perform(options = {})
    order = options[:order]
    promotion = options[:promotion]
    promotion_code = options[:promotion_code]
    create_unique_adjustments(order, order.line_items, promotion_code) do |line_item|
      promotion.line_item_actionable?(order, line_item)
    end
  end
end
