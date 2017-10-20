require 'spec_helper'

describe 'Checkout', type: :feature, inaccessible: true, js: true do
  let!(:country) { create(:country, states_required: true) }
  let!(:state) { create(:state, country: country) }
  let!(:shipping_method) { create(:shipping_method) }
  let!(:stock_location) { create(:stock_location) }
  let!(:mug) { create(:product, name: 'RoR Mug') }
  let!(:payment_method) { create(:check_payment_method) }
  let!(:zone) { create(:zone) }
  let!(:store) { create(:store) }

  let(:country) { create(:country, name: 'United States of America', iso_name: 'UNITED STATES') }
  let(:state) { create(:state, name: 'Alabama', abbr: 'AL', country: country) }

  context 'if coupon promotion, submits coupon along with payment', js: true do
    let!(:promotion) { create(:promotion, name: 'Huhuhu') }
    let!(:promotion_code) { create(:promotion_code, promotion: promotion, value: 'huhu') }
    let!(:calculator) { Spree::Calculator::FlatPercentItemTotal.create(preferred_flat_percent: '10') }
    let!(:action) { Spree::Promotion::Actions::CreateItemAdjustments.create(calculator: calculator) }

    before do
      promotion.actions << action

      add_mug_to_cart
      click_on 'Checkout'

      fill_in 'order_email', with: 'test@example.com'
      click_on 'Continue'
      fill_in_address
      click_on 'Save and Continue'

      click_on 'Save and Continue'
      expect(current_path).to eql(spree.checkout_state_path('payment'))
    end

    it 'makes sure payment reflects order total with discounts' do
      fill_in 'Coupon Code', with: promotion.codes.first.value
      click_on 'Save and Continue'

      expect(page).to have_content(promotion.name)
      expect(Spree::Payment.first.amount.to_f).to eq Spree::Order.last.total.to_f
    end

    context 'invalid coupon' do
      it 'doesnt create a payment record' do
        fill_in 'Coupon Code', with: 'invalid'
        click_on 'Save and Continue'

        expect(Spree::Payment.count).to eq 0
        expect(page).to have_content(Spree.t(:coupon_code_not_found))
      end
    end

    context "doesn't fill in coupon code input" do
      it 'advances just fine' do
        click_on 'Save and Continue'
        expect(current_path).to match(spree.order_path(Spree::Order.last))
      end
    end

    context 'the promotion makes order free (downgrade it total to 0.0)' do
      let(:promotion2) { Spree::Promotion.create(name: 'test-7450') }
      let!(:promotion_code2) { create(:promotion_code, promotion: promotion2, value: 'test-7450') }
      let(:calculator2) do
        Spree::Calculator::FlatRate.create(preferences: { currency: 'USD', amount: BigDecimal.new('99999') })
      end
      let(:action2) { Spree::Promotion::Actions::CreateItemAdjustments.create(calculator: calculator2) }

      before { promotion2.actions << action2 }

      context 'user choose to pay by check' do
        it 'move user to complete checkout step' do
          fill_in 'Coupon Code', with: promotion_code2.value
          click_on 'Save and Continue'

          expect(page).to have_content(promotion2.name)
          expect(Spree::Order.last.total.to_f).to eq(0)

          if Gem.loaded_specs['spree_core'].version < Gem::Version.create('3.3')
            click_on 'Save and Continue'
            click_on 'Save and Continue'
          end
          expect(current_path).to match(spree.order_path(Spree::Order.last))
        end
      end

      context 'user choose to pay by card' do
        let(:bogus) { create(:credit_card_payment_method) }
        before do
          order = Spree::Order.last
          allow(order).to receive_messages(available_payment_methods: [bogus])
          allow_any_instance_of(Spree::CheckoutController).to receive_messages(current_order: order)

          visit spree.checkout_state_path(:payment)
        end

        it 'move user to confirmation checkout step' do
          fill_in 'Name on card', with: 'Spree Commerce'
          fill_in 'Card Number', with: '4111111111111111'
          fill_in 'card_expiry', with: '04 / 20'
          fill_in 'Card Code', with: '123'

          fill_in 'Coupon Code', with: promotion_code2.value
          click_on 'Save and Continue'

          expect(page).to have_content(promotion2.name)
          expect(Spree::Order.last.total.to_f).to eq(0)

          if Gem.loaded_specs['spree_core'].version < Gem::Version.create('3.3')
            click_on 'Save and Continue'
            click_on 'Save and Continue'
            expect(current_path).to match(spree.order_path(Spree::Order.last))
          else
            expect(current_path).to eql(spree.checkout_state_path('confirm'))

          end
        end
      end
    end
  end

  def fill_in_address
    address = 'order_bill_address_attributes'
    fill_in "#{address}_firstname", with: 'Ryan'
    fill_in "#{address}_lastname", with: 'Bigg'
    fill_in "#{address}_address1", with: '143 Swan Street'
    fill_in "#{address}_city", with: 'Richmond'
    select country.name, from: "#{address}_country_id"
    select state.name, from: "#{address}_state_id"
    fill_in "#{address}_zipcode", with: '12345'
    fill_in "#{address}_phone", with: '(555) 555-5555'
  end

  def add_mug_to_cart
    visit spree.root_path
    click_link mug.name
    click_button 'add-to-cart-button'
  end
end
