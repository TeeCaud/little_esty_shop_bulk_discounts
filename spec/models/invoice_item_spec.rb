require 'rails_helper'

RSpec.describe InvoiceItem, type: :model do
  describe "validations" do
    it { should validate_presence_of :invoice_id }
    it { should validate_presence_of :item_id }
    it { should validate_presence_of :quantity }
    it { should validate_presence_of :unit_price }
    it { should validate_presence_of :status }
  end
  describe "relationships" do
    it { should belong_to :invoice }
    it { should belong_to :item }

    it { should have_one(:merchant).through(:item)}
    it { should have_many(:bulk_discounts).through(:merchant)}
  end

  describe "class methods" do
    before(:each) do
      @m1 = Merchant.create!(name: 'Merchant 1')
      @c1 = Customer.create!(first_name: 'Bilbo', last_name: 'Baggins')
      @c2 = Customer.create!(first_name: 'Frodo', last_name: 'Baggins')
      @c3 = Customer.create!(first_name: 'Samwise', last_name: 'Gamgee')
      @c4 = Customer.create!(first_name: 'Aragorn', last_name: 'Elessar')
      @c5 = Customer.create!(first_name: 'Arwen', last_name: 'Undomiel')
      @c6 = Customer.create!(first_name: 'Legolas', last_name: 'Greenleaf')
      @item_1 = Item.create!(name: 'Shampoo', description: 'This washes your hair', unit_price: 10, merchant_id: @m1.id)
      @item_2 = Item.create!(name: 'Conditioner', description: 'This makes your hair shiny', unit_price: 8, merchant_id: @m1.id)
      @item_3 = Item.create!(name: 'Brush', description: 'This takes out tangles', unit_price: 5, merchant_id: @m1.id)
      @i1 = Invoice.create!(customer_id: @c1.id, status: 2)
      @i2 = Invoice.create!(customer_id: @c1.id, status: 2)
      @i3 = Invoice.create!(customer_id: @c2.id, status: 2)
      @i4 = Invoice.create!(customer_id: @c3.id, status: 2)
      @i5 = Invoice.create!(customer_id: @c4.id, status: 2)
      @ii_1 = InvoiceItem.create!(invoice_id: @i1.id, item_id: @item_1.id, quantity: 13, unit_price: 10, status: 0)
      @ii_2 = InvoiceItem.create!(invoice_id: @i1.id, item_id: @item_2.id, quantity: 1, unit_price: 8, status: 0)
      @ii_3 = InvoiceItem.create!(invoice_id: @i2.id, item_id: @item_3.id, quantity: 1, unit_price: 5, status: 2)
      @ii_4 = InvoiceItem.create!(invoice_id: @i3.id, item_id: @item_3.id, quantity: 1, unit_price: 5, status: 1)

      @bulk_discount1 = BulkDiscount.create!(name: "20% OFF!", percentage: 20, quantity: 10, merchant_id: @m1.id)
      @bulk_discount2 = BulkDiscount.create!(name: "25% OFF!", percentage: 25, quantity: 12, merchant_id: @m1.id)
      @bulk_discount3 = BulkDiscount.create!(name: "30% OFF!", percentage: 30, quantity: 15, merchant_id: @m1.id)
    end
    it 'incomplete_invoices' do
      expect(InvoiceItem.incomplete_invoices).to eq([@i1, @i3])
    end
    it 'best_discount' do
      expect(@ii_1.best_discount).to eq(@bulk_discount2)
    end
    it 'total_revenue' do
      expect(@ii_1.total_revenue).to eq(130)
    end
    it 'discount_revenue' do
      expect(@ii_1.discount_revenue).to eq(32)
    end
    it 'discounted_price' do
      expect(@ii_1.discounted_price).to eq(98)
    end
    it 'applied_discount' do
      expect(@ii_1.applied_discount).to eq(@bulk_discount2.name)
      expect(@ii_4.applied_discount).to eq(nil)
    end
  end
end
