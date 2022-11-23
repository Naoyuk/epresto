# frozen_string_literal: true

module OrdersHelper
  def tab_link_to(path, text)
    classes = %w[inline-block py-2 px-4 font-semibold rounded-t-lg]
    classes << %w[bg-gray-200 text-grey-light] unless current_page?(path)
    classes << %w[bg-blue-600 text-white border-l border-t border-r border-blue-600
                  text-blue-dark] if current_page?(path)

    link_to(path, class: classes) do
      tag.span text
    end
  end

  def download_po_link_to
    if params[:new]
      state = { new: true }
    elsif params[:acknowledged]
      state = { acknowledged: true }
    elsif params[:rejected]
      state = { rejected: true }
    elsif params[:closed]
      state = { closed: true }
    else
      state = { all: true }
    end
    link_to(orders_path(**state, format: :xlsx), class: 'mx-4 py-2 px-4 bg-sky-400 text-white rounded') do
      tag.span 'Download PO'
    end
  end
end
