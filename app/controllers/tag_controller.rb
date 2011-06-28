class TagController < ApplicationController

  def show
    @blog_posts = BlogPost.published.tagged_with(params[:tag]).paginate(:page => params[:page], :per_page => 5)
    render :action => 'blog_posts/index.html.erb'
  end

end
