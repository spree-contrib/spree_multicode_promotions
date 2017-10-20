require 'spec_helper'
require 'spree/testing_support/bar_ability'

module Spree
  describe Api::V1::OrdersController, type: :controller do
    render_views

    let!(:order) { create(:order) }
    let(:variant) { create(:variant) }
    let(:line_item) { create(:line_item) }

    let(:attributes) do
      [:number, :item_total, :display_total, :total, :state, :adjustment_total, :user_id,
       :created_at, :updated_at, :completed_at, :payment_total, :shipment_state, :payment_state,
       :email, :special_instructions, :total_quantity, :display_item_total, :currency, :considered_risky]
    end

    let(:address_params) { { country_id: Country.first.id, state_id: State.first.id } }

    let(:current_api_user) do
      user = Spree.user_class.new(email: 'spree@example.com')
      user.generate_spree_api_key!
      user
    end

    before do
      stub_authentication!
    end

    describe '#apply_coupon_code' do
      let(:promo) { create(:promotion_with_item_adjustment, code: 'abc') }
      let(:promo_code) { promo.codes.first }

      before do
        allow_any_instance_of(Order).to receive_messages user: current_api_user
      end

      context 'when successful' do
        let(:order) { create(:order_with_line_items) }

        it 'applies the coupon' do
          api_put :apply_coupon_code, id: order.to_param, coupon_code: promo_code.value

          expect(response.status).to eq 200
          expect(order.reload.promotions).to eq [promo]
          expect(json_response).to eq(
            'success' => Spree.t(:coupon_code_applied),
            'error' => nil,
            'successful' => true,
            'status_code' => 'coupon_code_applied',
          )
        end
      end

      context 'when unsuccessful' do
        let(:order) { create(:order) } # no line items to apply the code to

        it 'returns an error' do
          api_put :apply_coupon_code, id: order.to_param, coupon_code: promo_code.value

          expect(response.status).to eq 422
          expect(order.reload.promotions).to eq []
          expect(json_response).to eq(
            'success' => nil,
            'error' => Spree.t(:coupon_code_unknown_error),
            'successful' => false,
            'status_code' => 'coupon_code_unknown_error',
          )
        end
      end
    end
  end
end
