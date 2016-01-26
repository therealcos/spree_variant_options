require 'spec_helper'

RSpec.describe 'Product Images', type: :feature, js: true do
  stub_authorization!

  let(:user) { create(admin_user) }

  let(:file_path) { Rails.root + '../../spec/fixtures/thinking-cat.jpg' }

  before do
    # Ensure attachment style keys are symbolized before running all tests
    # Otherwise this would result in this error:
    # undefined method `processors' for \"48x48>\
    Spree::Image.attachment_definitions[:attachment][:styles].symbolize_keys!
  end

  context 'product has variants' do
    let!(:product) { create(:product) }
    let!(:variant) { create(:variant, product: product) }
    let!(:other_variant) { create(:variant, product: product, option_values: variant.option_values) }

    describe 'create an image' do
      it 'allows user to upload the same image for multiple variants' do
        visit spree.admin_product_images_path(product)
        click_link "new_image_link"
        attach_file('image_attachment', file_path)
        check other_variant.option_values.first.presentation

        click_button "Update"
        expect(page).to have_content("successfully created!")

        within("table.table") do
          # Make sure we have an image for each variant
          expect(page).to have_css("tbody tr", :count => 2)

          # Make sure we are listing variants with images
          within("thead") do
            expect(page).to have_content("VARIANT")
          end
        end
      end

      describe 'user check All checkbox' do
        it 'allows user to upload an image to all variants' do
          visit spree.admin_product_images_path(product)
          click_link "new_image_link"
          attach_file('image_attachment', file_path)
          check 'All'

          # Disable other options
          page.all('.option-value').each do |ov_checkbox|
            ov_checkbox.should_not be_checked
          end

          click_button "Update"
          expect(page).to have_content("successfully created!")

          within("table.table") do
            expect(page).to have_css('tbody tr', :count => 1)
            expect(page).to have_content('All')
          end
        end
      end

    end

    describe 'update an image'
  end

  context 'product does not have variants' do
    let!(:product) { create(:product) }

    it 'uploads an image for product master variant' do
      visit spree.admin_product_images_path(product)
      click_link "new_image_link"
      attach_file('image_attachment', file_path)
      click_button "Update"
      expect(page).to have_content("successfully created!")

      within("table.table") do
        #ensure no duplicate images are displayed
        expect(page).to have_css("tbody tr", :count => 1)

        #ensure variant header is not displayed
        within("thead") do
          expect(page).to_not have_content("Variant")
        end

        #ensure correct cell count
        expect(page).to have_css("thead th", :count => 3)
      end
    end
  end
end