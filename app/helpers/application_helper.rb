module ApplicationHelper
  def sidebar_link_to(path, text)
    classes = %w[my-1 py-2 px-4 rounded text-white hover:bg-teal-600]
    classes << "active" if current_page?(path)

    link_to(path, class: classes) do
      tag.span { text }
    end
  end

  def icon(icon_name)
    tag.i(class: ['bi', "bi-#{icon_name}"])
  end

  def icon_with_text(icon_name, text)
    tag.span(icon(icon_name), class: 'me-2') + tag.span(text)
  end
end
