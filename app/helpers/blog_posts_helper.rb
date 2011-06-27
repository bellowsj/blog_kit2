module BlogPostsHelper

  def display_name(name, site)
    if !site.blank?
      return link_to(self.site_url, name)
    else
      return name
    end
  end

end
