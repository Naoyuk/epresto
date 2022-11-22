# frozen_string_literal: true

module OrdersHelper
  def tab_link_to(path, text)
    classes = %w[inline-block py-2 px-4 font-semibold rounded-t-lg]
    classes << %w[bg-gray-200 text-grey-light] unless current_page?(path)
    classes << %w[bg-blue-600 text-white border-l border-t border-r border-blue-600 text-blue-dark] if current_page?(path)

    link_to(path, class: classes) do
      tag.span text
    end
  end
end
