require 'spec_helper'

describe 'spree/admin/images/_form.html.erb' do
  let(:product) { create(:product) }

  before do
    assigns(:product).to be(product)
  end

  context 'product has variants' do
    before do
      product.variants << create_list(:variant, 5, product: product)
      product.save

      assign(:grouped_option_values, product.option_values.group_by(&:option_type))
    end

    it 'shows an \'All\' checkbox with the product master variant id as value' do
      render
      expect(rendered).to include("<input id=\"master_option\" name=\"master_option\" type=\"checkbox\" value=\"1\" />")
      expect(rendered).to include("<label for=\"master_option\">All</label>")
    end

    it 'shows checkboxes for selecting which variants will receive the uploaded image' do
      render
      product.option_types.each do |ot|
        expect(rendered).to include("option_type_#{ot.id}")
      end
      product.option_values.each do |ov|
        expect(rendered).to include("image[viewable_id][#{ov.id}]")
      end
    end
  end

  context 'product does not have variants' do
    let(:variants) { [create(:variant)] }

    before do
      assign(:grouped_option_values, {})
      assign(:variants, variants)
      allow(view).to receive_message_chain(:f, :select) { 'A select' }
    end

    it 'shows a select with a single option' do
      render
      expect(rendered).to_not include('option_type')
      expect(rendered).to include('A select')
    end
  end
end