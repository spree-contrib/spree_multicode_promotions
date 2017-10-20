Spree::Adjustment.class_eval do
  belongs_to :promotion_code, class_name: 'Spree::PromotionCode'

  def update!(target = adjustable)
    return amount if closed? || source.blank?
    amount = source.compute_amount(target)
    attributes = { amount: amount, updated_at: Time.current }
    attributes[:eligible] = source.promotion.eligible?(target, promotion_code: promotion_code) if promotion?
    update_columns(attributes)
    amount
  end
end
