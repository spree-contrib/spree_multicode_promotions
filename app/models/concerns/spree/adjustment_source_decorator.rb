Spree::AdjustmentSource.module_eval do
  protected

  def create_adjustment(order, adjustable, promotion_code, included = false)
    amount = compute_amount(adjustable)
    return if amount == 0
    adjustments.new(order: order,
                    adjustable: adjustable,
                    promotion_code: promotion_code,
                    label: label,
                    amount: amount,
                    included: included).save
  end

  def create_unique_adjustment(order, adjustable, promotion_code)
    return if already_adjusted?(adjustable)
    create_adjustment(order, adjustable, promotion_code)
  end

  def create_unique_adjustments(order, adjustables, promotion_code)
    adjustables.where.not(id: already_adjusted_ids(order)).map do |adjustable|
      create_adjustment(order, adjustable, promotion_code) if !block_given? || yield(adjustable)
    end.any?
  end
end
