Spree::Promotion::Actions::CreateAdjustment.class_eval do
  def perform(options = {})
    order = options[:order]
    promotion_code = options[:promotion_code]
    create_unique_adjustment(order, order, promotion_code)
  end
end
