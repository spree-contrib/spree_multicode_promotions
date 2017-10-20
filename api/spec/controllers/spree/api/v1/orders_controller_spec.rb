module Spree
  describe Api::V1::OrdersController, type: :controller do

    describe '#apply_coupon_code' do
      let(:promo) { create(:multicode_promotion_with_item_adjustment, code: 'abc') }
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
