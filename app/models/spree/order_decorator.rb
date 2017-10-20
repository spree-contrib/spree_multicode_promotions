Spree::Order.class_eval do
  self.whitelisted_ransackable_associations = %w[shipments user promotions bill_address ship_address line_items promotions_codes] # its wrong!

  def promo_code
    promotions.includes(:codes).pluck(:value).compact.first
  end
end

