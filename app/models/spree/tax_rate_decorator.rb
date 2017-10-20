Spree::TaxRate.class_eval do
  def adjust(order, item)
    create_adjustment(order, item, nil, included_in_price)
  end
end
