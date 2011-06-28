module BlogHelper

  def display_name(name, site)
    if !site.blank?
      return link_to(name, site)
    else
      return name
    end
  end

end
