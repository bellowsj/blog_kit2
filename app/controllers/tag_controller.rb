class TagController < ApplicationController

  def show
    @blog_posts = BlogPost.tagged_with(params[:tag])
    render :action => 'blog_posts/index.html.erb'
  end

end
