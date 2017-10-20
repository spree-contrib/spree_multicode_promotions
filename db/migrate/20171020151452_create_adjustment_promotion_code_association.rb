class CreateAdjustmentPromotionCodeAssociation < SpreeExtension::Migration[4.2]
  def change
    create_table :adjustment_promotion_code_associations do |t|
      add_column :spree_adjustments, :promotion_code_id, :integer
      add_index :spree_adjustments, :promotion_code_id
    end
  end
end
