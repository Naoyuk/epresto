class AddCatalogueColumnsToItem < ActiveRecord::Migration[7.0]
  def change
    add_column :items, :vendor_code, :string
    add_column :items, :vendor_sKU, :string
    add_column :items, :product_type, :string
    add_column :items, :item_name, :string
    add_column :items, :brand_name, :string
    add_column :items, :external_product_id, :string
    add_column :items, :external_product_id_type, :string
    add_column :items, :merchant_suggested_asin, :string
    add_column :items, :external_id_exemption_reason, :string
    add_column :items, :product_category, :string
    add_column :items, :product_subcategory, :string
    add_column :items, :recommended_browse_nodes1, :string
    add_column :items, :recommended_browse_nodes2, :string
    add_column :items, :recommended_browse_nodes3, :string
    add_column :items, :recommended_browse_nodes4, :string
    add_column :items, :recommended_browse_nodes5, :string
    add_column :items, :package_level, :string
    add_column :items, :package_contains_quantity, :string
    add_column :items, :package_contains_identifier, :string
    add_column :items, :is_package_level_orderable, :string
    add_column :items, :item_type_name, :string
    add_column :items, :manufacturer, :string
    add_column :items, :list_price, :string
    add_column :items, :list_price_currency, :string
    add_column :items, :cost_price, :string
    add_column :items, :cost_price_currency, :string
    add_column :items, :bullet_point1, :string
    add_column :items, :bullet_point2, :string
    add_column :items, :bullet_point3, :string
    add_column :items, :bullet_point4, :string
    add_column :items, :bullet_point5, :string
    add_column :items, :generic_keyword1, :string
    add_column :items, :generic_keyword2, :string
    add_column :items, :generic_keyword3, :string
    add_column :items, :generic_keyword4, :string
    add_column :items, :generic_keyword5, :string
    add_column :items, :number_of_items, :string
    add_column :items, :product_description, :string
    add_column :items, :color, :string
    add_column :items, :occasion1, :string
    add_column :items, :occasion2, :string
    add_column :items, :occasion3, :string
    add_column :items, :occasion4, :string
    add_column :items, :occasion5, :string
    add_column :items, :serving_recommendation, :string
    add_column :items, :is_the_item_heat_Sensitive?, :string
    add_column :items, :melting_temperature_degrees_celsius, :string
    add_column :items, :melting_temperature_unit, :string
    add_column :items, :temperature_rating, :string
    add_column :items, :material_type_free1, :string
    add_column :items, :material_type_free2, :string
    add_column :items, :material_type_free3, :string
    add_column :items, :material_type_free4, :string
    add_column :items, :material_type_free5, :string
    add_column :items, :flavor, :string
    add_column :items, :form_factor, :string
    add_column :items, :ingredients, :string
    add_column :items, :cuisine, :string
    add_column :items, :each_unit_count, :string
    add_column :items, :allergen_information1, :string
    add_column :items, :allergen_information2, :string
    add_column :items, :allergen_information3, :string
    add_column :items, :allergen_information4, :string
    add_column :items, :allergen_information5, :string
    add_column :items, :is_product_expirable, :string
    add_column :items, :product_expiration_type, :string
    add_column :items, :fulfillment_center_shelf_life, :string
    add_column :items, :fulfillment_center_shelf_life_Unit, :string
    add_column :items, :item_form, :string
    add_column :items, :specialty1, :string
    add_column :items, :specialty2, :string
    add_column :items, :specialty3, :string
    add_column :items, :specialty4, :string
    add_column :items, :specialty5, :string
    add_column :items, :release_date, :string
    add_column :items, :product_site_launch_date, :string
    add_column :items, :unit_count, :string
    add_column :items, :unit_count_type, :string
    add_column :items, :container_type, :string
    add_column :items, :manufacturer_contact_information1, :string
    add_column :items, :manufacturer_contact_information2, :string
    add_column :items, :manufacturer_contact_information3, :string
    add_column :items, :manufacturer_contact_information4, :string
    add_column :items, :manufacturer_contact_information5, :string
    add_column :items, :diet_type1, :string
    add_column :items, :diet_type2, :string
    add_column :items, :diet_type3, :string
    add_column :items, :nut_or_seed_type1, :string
    add_column :items, :nut_or_seed_type2, :string
    add_column :items, :nut_or_seed_type3, :string
    add_column :items, :nut_or_seed_type4, :string
    add_column :items, :nut_or_seed_type5, :string
    add_column :items, :directions, :string
    add_column :items, :region_of_origin, :string
    add_column :items, :country_of_origin, :string
    add_column :items, :warranty_description1, :string
    add_column :items, :warranty_description2, :string
    add_column :items, :warranty_description3, :string
    add_column :items, :warranty_description4, :string
    add_column :items, :warranty_description5, :string
    add_column :items, :safety_warning, :string
    add_column :items, :are_batteries_required?, :string
    add_column :items, :are_batteries_included?, :string
    add_column :items, :battery_cell_composition, :string
    add_column :items, :battery_weight, :string
    add_column :items, :battery_weight_unit, :string
    add_column :items, :number_of_batteries1, :string
    add_column :items, :battery_type1, :string
    add_column :items, :number_of_batteries2, :string
    add_column :items, :battery_type2, :string
    add_column :items, :number_of_batteries3, :string
    add_column :items, :battery_type3, :string
    add_column :items, :number_of_batteries4, :string
    add_column :items, :battery_type4, :string
    add_column :items, :number_of_batteries5, :string
    add_column :items, :battery_type5, :string
    add_column :items, :number_of_lithium_metal_cells, :string
    add_column :items, :number_of_lithium_ion_cells, :string
    add_column :items, :lithium_battery_energy_content, :string
    add_column :items, :lithium_battery_energy_content_unit, :string
    add_column :items, :lithium_battery_packaging, :string
    add_column :items, :lithium_battery_weight, :string
    add_column :items, :lithium_battery_weight_unit, :string
    add_column :items, :dangerous_goods_regulations1, :string
    add_column :items, :dangerous_goods_regulations2, :string
    add_column :items, :dangerous_goods_regulations3, :string
    add_column :items, :dangerous_goods_regulations4, :string
    add_column :items, :dangerous_goods_regulations5, :string
    add_column :items, :contains_liquid_contents?, :string
    add_column :items, :hazmat_aspect, :string
    add_column :items, :hazmat, :string
    add_column :items, :liquid_contents_uescription, :string
    add_column :items, :safety_data_sheet_sds_or_msds_url, :string
    add_column :items, :item_weight, :string
    add_column :items, :item_weight_unit, :string
    add_column :items, :product_compliance_certificate, :string
    add_column :items, :regulatory_organization_name, :string
    add_column :items, :compliance_certification_status, :string
    add_column :items, :compliance_certification_value, :string
    add_column :items, :certification_metadata, :string
    add_column :items, :certification_date_of_issue, :string
    add_column :items, :certification_expiration_date, :string
    add_column :items, :gHS_class, :string
    add_column :items, :liquid_packaging_type, :string
    add_column :items, :is_the_liquid_product_double_sealed?, :string
    add_column :items, :mandatory_cautionary_statement1, :string
    add_column :items, :mandatory_cautionary_statement2, :string
    add_column :items, :mandatory_cautionary_statement3, :string
    add_column :items, :mandatory_cautionary_statement4, :string
    add_column :items, :mandatory_cautionary_statement5, :string
    add_column :items, :liquid_volume_unit, :string
    add_column :items, :liquid_volume, :string
    add_column :items, :compliance_regulation_type1, :string
    add_column :items, :regulatory_identification1, :string
    add_column :items, :compliance_regulation_type2, :string
    add_column :items, :regulatory_identification2, :string
    add_column :items, :compliance_regulation_type3, :string
    add_column :items, :regulatory_identification3, :string
    add_column :items, :compliance_regulation_type4, :string
    add_column :items, :regulatory_identification4, :string
    add_column :items, :compliance_regulation_type5, :string
    add_column :items, :regulatory_identification5, :string
    add_column :items, :item_length, :string
    add_column :items, :item_length_unit, :string
    add_column :items, :item_width, :string
    add_column :items, :item_width_unit, :string
    add_column :items, :item_height, :string
    add_column :items, :item_height_unit, :string
    add_column :items, :item_package_length, :string
    add_column :items, :package_length_unit, :string
    add_column :items, :item_package_width, :string
    add_column :items, :package_width_unit, :string
    add_column :items, :item_package_height, :string
    add_column :items, :package_height_unit, :string
    add_column :items, :package_weight, :string
    add_column :items, :package_weight_unit, :string
    add_column :items, :item_volume, :string
    add_column :items, :item_volume_unit, :string
    add_column :items, :items_per_inner_pack, :string
    add_column :items, :inner_packs_per_master_pack, :string
    add_column :items, :master_pack_layers_per_pallet_quantity, :string
    add_column :items, :master_packs_per_layer_quantity, :string
  end
end