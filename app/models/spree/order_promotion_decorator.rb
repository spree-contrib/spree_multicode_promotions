Spree::OrderPromotion.class_eval do
  belongs_to :promotion_code, class_name: 'Spree::PromotionCode'
end
