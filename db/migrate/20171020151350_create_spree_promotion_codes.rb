class CreateSpreePromotionCodes < SpreeExtension::Migration[4.2]
  def change
    create_table :spree_promotion_codes do |t|
      t.references :promotion, index: true, null: false
      t.string :value, null: false

      t.timestamps
    end

    add_index :spree_promotion_codes, :value, unique: true
  end
end
