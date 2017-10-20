Spree::PromotionHandler::FreeShipping.class_eval do
  def activate
    promotions.each do |promotion|
      next if promotion.codes.any? && !order_promo_ids.include?(promotion.id)

      promotion.activate(order: order) if promotion.eligible?(order)
    end
  end

  private

  def promotions
    promo_table = Spree::Promotion.arel_table
    code_table  = Spree::PromotionCode.arel_table

    promotion_code_join = promo_table.join(code_table, Arel::Nodes::OuterJoin).on(
      promo_table[:id].eq(code_table[:promotion_id])
    ).join_sources

    Spree::Promotion.active.
      joins(promotion_code_join).
      where(
        id: Spree::Promotion::Actions::FreeShipping.pluck(:promotion_id), # This would probably be more efficient by joining instead
        path: nil
    )
  end
end
