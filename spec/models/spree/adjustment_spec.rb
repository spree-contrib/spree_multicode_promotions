require 'spec_helper'

describe Spree::Adjustment, type: :model do
  let(:order) { Spree::Order.new }

  before do
    allow(order).to receive(:update_with_updater!)
  end

  let(:adjustment) { Spree::Adjustment.create!(label: 'Adjustment', adjustable: order, order: order, amount: 5) }

  context '#update!' do
    subject { adjustment.update! }

    context 'when adjustment is closed' do
      before { allow(adjustment).to receive(:closed?).and_return(true) }

      it 'does not update the adjustment' do
        expect(adjustment).to_not receive(:update_column)
        subject
      end
    end

    context 'when adjustment is open' do
      before { allow(adjustment).to receive(:closed?).and_return(false) }

      it 'updates the amount' do
        expect(adjustment).to receive(:adjustable).and_return(double('Adjustable')).at_least(1).times
        expect(adjustment).to receive(:source).and_return(double('Source')).at_least(1).times
        expect(adjustment.source).to receive('compute_amount').with(adjustment.adjustable).and_return(5)
        expect(adjustment).to receive(:update_columns).with(amount: 5, updated_at: kind_of(Time))
        subject
      end

      context 'it is a promotion adjustment' do
        subject { @adjustment.update! }

        let!(:promotion) { create(:multicode_promotion, :with_order_adjustment) }
        let!(:promotion_code) { create(:promotion_code, promotion: promotion) }
        let!(:order_for_promotion) { create(:order_with_line_items, line_items_count: 1) }

        before do
          promotion.activate(order: order_for_promotion, promotion_code: promotion_code)
          expect(order_for_promotion.adjustments.size).to eq 1
          @adjustment = order_for_promotion.adjustments.first
        end

        context 'the promotion is eligible' do
          it 'sets the adjustment elgiible to true' do
            subject
            expect(@adjustment.eligible).to eq true
          end
        end

        context 'the promotion is not eligible' do
          before { promotion.update_attributes!(starts_at: 1.day.from_now) }

          it 'sets the adjustment elgiible to false' do
            subject
            expect(@adjustment.eligible).to eq false
          end
        end
      end
    end
  end
end
