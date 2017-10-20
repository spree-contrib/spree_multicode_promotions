class AddPromotionCodeIdToOrdersPromotions < SpreeExtension::Migration[4.2]
  def change
    add_column :spree_order_promotions, :promotion_code_id, :integer
    add_index :spree_order_promotions, :promotion_code_id
  end
end
