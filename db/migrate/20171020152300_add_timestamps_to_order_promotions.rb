class AddTimestampsToOrderPromotions < SpreeExtension::Migration[4.2]
  def change
    add_column :spree_order_promotions, :created_at, :datetime
    add_column :spree_order_promotions, :updated_at, :datetime
  end
end
