Spree::PromotionHandler::Cart.class_eval do
  def activate
    promotions.each do |promotion|
      if (line_item && promotion.eligible?(line_item, promotion_code: promotion_code(promotion))) ||
          promotion.eligible?(order, promotion_code: promotion_code(promotion))
        promotion.activate(line_item: line_item, order: order, promotion_code: promotion_code(promotion))
      end
    end
  end

  private

  # Reverting 715d4439f4f02a1d75b8adac74b77dd445b61908 here to add promotion_code join.
  # Might be good to combine these two.
  def promotions
    Spree::Promotion.find_by_sql("#{order.promotions.active.to_sql} UNION #{Spree::Promotion.active.where(code: nil, path: nil).to_sql}")
    connected_order_promotions | sale_promotions
  end

  def connected_order_promotions
    Spree::Promotion.active.includes(:promotion_rules).
      joins(:order_promotions).
      where(spree_order_promotions: { order_id: order.id }).readonly(false).to_a
  end

  def sale_promotions
    promo_table = Spree::Promotion.arel_table
    code_table  = Spree::PromotionCode.arel_table

    promotion_code_join = promo_table.join(code_table, Arel::Nodes::OuterJoin).on(
      promo_table[:id].eq(code_table[:promotion_id])
    ).join_sources

    Spree::Promotion.active.includes(:promotion_rules).joins(promotion_code_join).
      where(code_table[:value].eq(nil).and(promo_table[:path].eq(nil))).distinct
  end

  def promotion_code(promotion)
    order_promotion = Spree::OrderPromotion.find_by(order: order, promotion: promotion)
    order_promotion.present? ? order_promotion.promotion_code : nil
  end
end
