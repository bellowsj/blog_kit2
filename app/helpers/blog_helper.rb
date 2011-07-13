module BlogHelper

  def display_name(name, site)
    if !site.blank?
      return link_to(name, site)
    else
      return name
    end
  end

  #def carnonical_link(post)
  #  "<link rel=\"canonical\" href=\"http://bottiger.org".html_safe + url_for(post) + "\"/>".html_safe
  #end

end
