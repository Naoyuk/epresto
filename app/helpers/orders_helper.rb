# frozen_string_literal: true

module OrdersHelper
  def tab_link_to(path, text)
    classes = %w[inline-block py-2 px-4 font-semibold rounded-t-lg]
    if request.query_string.include?("tab=#{text.downcase}")
      classes << %w[bg-blue-600 text-white border-l border-t border-r border-blue-600 text-blue-dark]
    else
      classes << %w[bg-gray-200 text-grey-light]
    end

    link_to(path, class: classes) do
      tag.span text
    end
  end

  def download_po_link_to
    if request.query_string.include?("tab=new")
      state = { tab: 'new' }
    elsif request.query_string.include?("tab=acknowledged")
      state = { tab: 'acknowledged' }
    elsif request.query_string.include?("tab=rejected")
      state = { tab: 'rejected' }
    elsif request.query_string.include?("tab=closed")
      state = { tab: 'closed' }
    else
      state = { tab: 'all' }
    end
    link_to(orders_path(**state, format: :xlsx), class: 'mx-4 py-2 px-4 bg-sky-400 text-white rounded') do
      tag.span 'Download PO'
    end
  end

  def download_js_link_to
    if request.query_string.include?("tab=new")
      state = { tab: 'new' }
    elsif request.query_string.include?("tab=acknowledged")
      state = { tab: 'acknowledged' }
    elsif request.query_string.include?("tab=rejected")
      state = { tab: 'rejected' }
    elsif request.query_string.include?("tab=closed")
      state = { tab: 'closed' }
    else
      state = { tab: 'all' }
    end
    link_to(orders_path(**state, format: :csv), class: 'mx-4 py-2 px-4 bg-sky-400 text-white rounded') do
      tag.span 'Download JS Import file'
    end
  end
end
