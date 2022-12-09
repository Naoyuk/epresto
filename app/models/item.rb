# frozen_string_literal: true

class Item < ApplicationRecord
  belongs_to :vendor
  has_many :order_items

  enum availability_status: {
    Current: 0,
    Discontinued: 1,
    Future: 2
  }

  enum case: {
    Case: true,
    Each: false
  }

  belongs_to :vendor

  def case_or_each
    pattern = /.*kg.*/
    if self.title.match(pattern)
      self.case = true
    else
      self.case = false
    end
    self.save
  end

  class << self
    def import(file, vendor_id)
      # インポートするファイルの読み込み
      xls = Roo::Excelx.new(file)

      # インポート対象のシートを取得
      type = file.original_filename.include?('.xlsx') ? 'xlsx' : 'xlsm'
      if type == 'xlsx'
        # GregAmazon_ItemInfo.xlsxは1シートのみ
        sheet = xls.sheets_arr[0]
#
        # 既存レコードの更新、または新規レコードを作成
        update_or_create_items(sheet, cols(cols_xls), vendor_id)
      else
        # Catalogue_Sourcing.xlsmは複数シートでカラム名がその都度異なる
        sheets_arr = xls.sheets.select { |sheet| sheet.include?("Template-") }

        # 各sheetを取り込み
        sheets_arr.each do |s|
          sheet_obj = xls.sheet(s)
          cols_xls = sheet_obj.row(3)
  #
          # 既存レコードの更新、または新規レコードを作成
          update_or_create_items(sheet_obj, cols(cols_xls), vendor_id)
        end
      end
    end

    def cols(cols_xls)
      # Item.coumn_names とcols_xlsの共通カラムだけ抽出して{'取り込み元のカラム'=>'DBのカラム'}を作る

      cols_hash = {}
      cols_db = Item.column_names
      cols_xls.map do |col|
        col_db = col.downcase.gsub(' ', '_')
        if cols_db.include?(col_db)
          cols_hash[col] = col_db
        end
      end
      cols_hash
    end

    def update_or_create_items(sheet, cols, vendor_id)
      # 処理対象のsheetとそのsheetにあるカラムの対照表Hashとvendor_idを受け取る
      if sheet.row(3).include?('Merchant Suggested Asin')
        # Catalogue_Sourcingファイルの場合はASINで検索して既存または新規レコードオブジェクトを作成
        headers = sheet.row(3)
        key = { asin: sheet.row(3).index('Merchant Suggested Asin') }
        first_row = 6
        catalogue = true
      else
        # GregAmazon_ItemInfoの場合はItemCodeで検索
        headers = sheet.row(1)
        key = { item_code: sheet.row(1).index('I_ITEM_CODE') }
        first_row = 2
        catalogue = false
      end

      (first_row..sheet.last_row).each do |row_num|
        prop = key.keys[0]
        if Item.send("find_by_#{prop}", sheet.row(row_num)[key.values[0]]).nil?
          item = Item.new
        else
          item = Item.send("find_by_#{prop}", sheet.row(row_num)[key.values[0]])
        end
        
        cols.each do |col|
          col_index = headers.index(col[0])
          val = sheet.row(row_num)[col_index]
          # val = sheet.row(row_num).index(col[0])
          item[col[1]] = val
        end
        item.vendor_id = vendor_id
        # item_params[:price] = row[6].delete('$').to_f
        if catalogue
          # インポート元がCatalogue_Sourcingファイルの場合、UPC, EAN, GTIN, ASINを設定する
          # Catalogue_SourcingはAmazonから取得するItemのマスタ
          # UPC, EAN, GTINは全てcheck digitが付加されている
          item.asin = item.merchant_suggested_asin
          case item.external_product_id_type
          when 'UPC'
            item.upc = item.external_product_id
          when 'EAN'
            item.ean = item.external_product_id
          when 'GTIN'
            item.gtin = item.external_product_id
          end
        else
          # インポート元がGregAmazon_ItemInfoの場合、必要なレコードに絞ってmixed_codesを更新
          # GregAmazon_ItemInfoはCCWのAccessDBから取得するItemのマスタ
          # 不要なデータがあるので、それはスキップする
          # mixed_codesにUPC, EAN, GTINのそれぞれcheck digit有り、無しが全て混在する
        end
        item.save
      end
    end
  end
end
