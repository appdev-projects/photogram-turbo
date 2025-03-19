module ApplicationHelper
  def only_host_and_path(input_url)
    if input_url.present?
      url = URI(input_url)

      link_to url.host + url.path, input_url, class: "link-underline link-underline-opacity-0 link-underline-opacity-100-hover"
    else
      nil
    end
  end
end
