class Item < ApplicationRecord
  belongs_to :vendor
  has_many :order_items

  enum status: {
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
      logger.debug "fileパス: #{file}"
      # インポートするファイルの読み込み
      xls = Roo::Excelx.new(file)

      # インポート対象のシートを取得
      type = file.original_filename.include?('qryGREG_Amazon_ItemInfo') ? 'ccw' : 'amazon'
      if type == 'ccw'
        # GregAmazon_ItemInfo.xlsxは1シートのみ
        sheet_obj = xls.sheet(xls.sheets[0])
        cols_xls = sheet_obj.row(1)

        # 既存レコードの更新、または新規レコードを作成
        update_items_access(sheet_obj, cols_access(cols_xls), vendor_id)
      else
        logger.debug 'Catalogファイルの取り込みを開始'
        # Catalogue.xlsxは複数シートでカラム名がその都度異なる
        sheets_arr = xls.sheets.select { |sheet| sheet.include?("Template-") }

        # 各sheetを取り込み
        sheets_arr.each do |s|
          sheet_obj = xls.sheet(s)
          cols_xls = sheet_obj.row(3)

          # 既存レコードの更新、または新規レコードを作成
          update_or_create_items(sheet_obj, cols_catalog(cols_xls), vendor_id)
        end
      end
    end

    def cols_access(cols_xls)
      # Item.coumn_names とcols_xlsの共通カラムだけ抽出して{'取り込み元のカラム'=>'DBのカラム'}を作る

      cols_hash = {}
      cols_db = Item.column_names
      cols_xls.map do |col|
        col_db = col.gsub('I_', '').downcase
        case col_db
        when 'item'
          col_db = 'title'
        when 'wholesale'
          col_db = 'price'
        when 'im_case_upc'
          col_db = 'external_product_id'
        end
        if cols_db.include?(col_db)
          cols_hash[col] = col_db
        end
      end
      # cols_hash.delete('I_UPC')
      cols_hash
    end

    def cols_catalog(cols_xls)
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

    def check_digit(code)
      arr = code.split('').map { |n| n.to_i }
      idx = arr.count.odd? ? 0 : 1
      odds = arr.map.with_index(1) { |n, i| n if i % 2 == idx }.compact
      evens = arr.map.with_index(1) { |n, i| n if i % 2 == (1 - idx) }.compact
      sum = odds.sum + evens.sum * 3
      ((10 - sum % 10) % 10).to_s
    end

    def update_or_create_items(sheet, cols, vendor_id)
      # 処理対象のsheetとそのsheetにあるカラムの対照表Hashとvendor_idを受け取る
      # Catalogue_Sourcingファイルの場合はASINで検索して既存または新規レコードオブジェクトを作成
      headers = sheet.row(3)

      (7..sheet.last_row).each do |row_num|
        idx = headers.index('Merchant Suggested Asin')
        if Item.find_by_asin(sheet.row(row_num)[idx]).nil?
          item = Item.new
        else
          item = Item.find_by_asin(sheet.row(row_num)[idx])
        end

        cols.each do |col|
          col_index = headers.index(col[0])
          val = sheet.row(row_num)[col_index]
          item[col[1]] = val
        end
        item.vendor_id = vendor_id
        # インポート元がCatalogue_Sourcingファイルの場合、UPC, EAN, GTIN, ASINを設定する
        # Catalogue_SourcingはAmazonから取得するItemのマスタ
        # UPC, EAN, GTINは全てcheck digitが付加されている
        item.asin = item.merchant_suggested_asin
        item.model_number = item.vendor_sku
        case item.external_product_id_type
        when 'UPC'
          item.upc = item.external_product_id
        when 'EAN'
          item.ean = item.external_product_id
        when 'GTIN'
          item.gtin = item.external_product_id
        end
        unless item.valid?
        end
        item.save
      end
    end

    def update_items_access(sheet, cols, vendor_id)
      # 処理対象のsheetとそのsheetにあるカラムの対照表Hashとvendor_idを受け取る
      # GregAmazon_ItemInfoの場合はItemCodeで検索
      headers = sheet.row(1)
      # headers.delete('I_UPC')

      (2..sheet.last_row).each do |row_num|
        index_of_im_case_upc = headers.index('IM_CASE_UPC')
        key = sheet.row(row_num)[index_of_im_case_upc]
        unless key.nil?
          case key.size
          when 11
            # 11桁で検索してヒットしたらCD無しのUPCに確定
            item = Item.find_by_external_product_id(key)
            unless item.nil?
              item.upc = key
              update_item_access(item, sheet, cols, headers, row_num, vendor_id)
            end

          when 12
            item = Item.find_by_external_product_id(key)
            unless item.nil?
              # 12桁のままで検索してヒットした場合
              if item.external_product_id_type == 'UPC'
                # typeがUPCならCD有りのUPCに確定
                item.upc = key
                update_item_access(item, sheet, cols, headers, row_num, vendor_id)
              elsif item.external_product_id_type == 'EAN'
                # typeがEANならCD無しのEANに確定
                item.ean = key
                update_item_access(item, sheet, cols, headers, row_num, vendor_id)
              end
            else
              # 12桁のままでヒットしなかったのでCD付けて検索してヒットした場合はCD有りのEANに確定
              item = Item.find_by_external_product_id(key + check_digit(key))
              unless item.nil?
                item.ean = key
                update_item_access(item, sheet, cols, headers, row_num, vendor_id)
              end
            end

          when 13
            item = Item.find_by_external_product_id(key)
            unless item.nil?
              # 13桁のままで検索してヒットした場合
              if item.external_product_id_type == 'EAN'
                # typeがEANならCD有りのEANに確定
                item.ean = key
                update_item_access(item, sheet, cols, headers, row_num, vendor_id)
              elsif item.external_product_id_type == 'GTIN'
                # typeがGTINならCD無しのGTINに確定
                item.gtin = key
                update_item_access(item, sheet, cols, headers, row_num, vendor_id)
              end
            else
              # 13桁のままでヒットしなかったのでCD付けて検索してヒットした場合はCD有りのGTINに確定
              item = Item.find_by_external_product_id(key + check_digit(key))
              unless item.nil?
                item.gtin = key
                update_item_access(item, sheet, cols, headers, row_num, vendor_id)
              end
            end

          when 14
            item = Item.find_by_external_product_id(key)
            unless item.nil?
              # 14桁で検索してヒットしたらCD有りのGTINに確定
              item.gtin = key
              update_item_access(item, sheet, cols, headers, row_num, vendor_id)
            end
          end
        end
      end
    end

    def update_item_access(item, sheet, cols, headers, row_num, vendor_id)
      cols.each do |col|
        unless col[0] == 'I_UPC'
          col_index = headers.index(col[0])
          val = sheet.row(row_num)[col_index]
          item[col[1]] = val
        end
      end
      item.vendor_id = vendor_id
      item.save
    end
  end
end
