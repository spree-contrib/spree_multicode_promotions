require 'spec_helper'

describe 'Cart', type: :feature, inaccessible: true do
  let!(:variant) { create(:variant) }
  let!(:product) { variant.product }

  def add_mug_to_cart
    visit spree.root_path
    click_link product.name
    click_button 'add-to-cart-button'
  end

  describe 'add promotion coupon on cart page', js: true do
    let!(:promotion) { Spree::Promotion.create(name: 'Huhuhu') }
    let!(:code) { promotion.codes.create(value: 'huhu') }
    let!(:calculator) { Spree::Calculator::FlatPercentItemTotal.create(preferred_flat_percent: '10') }
    let!(:action) { Spree::Promotion::Actions::CreateItemAdjustments.create(calculator: calculator) }

    before do
      skip 'Spree 3.1 doesnt have coupon on cart' if Gem.loaded_specs['spree_core'].version < Gem::Version.create('3.2')
      promotion.actions << action
      add_mug_to_cart
      expect(current_path).to eql(spree.cart_path)
    end

    def apply_coupon(code)
      fill_in 'Coupon Code', with: code
      click_on 'Update'
    end

    context 'valid coupon' do
      before { apply_coupon(promotion.codes.first.value) }

      context 'for the first time' do
        it 'makes sure payment reflects order total with discounts' do
          expect(page).to have_content(promotion.name)
        end
      end

      context 'same coupon for the second time' do
        before { apply_coupon(promotion.codes.first.value) }
        it 'should reflect an error that coupon already applied' do
          apply_coupon(promotion.codes.first.value)
          expect(page).to have_content(Spree.t(:coupon_code_already_applied))
          expect(page).to have_content(promotion.name)
        end
      end
    end

    context 'invalid coupon' do
      it 'doesnt create a payment record' do
        apply_coupon('invalid')
        expect(page).to have_content(Spree.t(:coupon_code_not_found))
      end
    end

    context "doesn't fill in coupon code input" do
      it 'advances just fine' do
        click_on 'Update'
        expect(current_path).to match(spree.cart_path)
      end
    end
  end
end
