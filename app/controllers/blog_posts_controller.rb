class BlogPostsController < ApplicationController
	unloadable
	
	layout(BlogKit.instance.settings['layout'] || 'application')
	
	before_filter :require_user, :except => [:index, :show]
	before_filter :require_admin, :except => [:index, :show]

	
  def index
    @blog_posts = BlogPost.published.paginate(:page => params[:page], :per_page => 5, :order => 'published_at DESC')

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @blog_posts }
			format.atom
    end
  end

  def drafts
    @blog_posts = BlogPost.drafts.paginate(:page => params[:page], :order => 'updated_at DESC')

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @blog_posts }
    end
  end

  def show
    @blog_post = BlogPost.find(params[:id])
		@blog_comment = @blog_post.blog_comments.new
		@blog_comments = @blog_post.blog_comments.paginate(:page => params[:page], :order => 'created_at DESC')

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @blog_post }
    end
  end

  def new
		puts "made it"
    @blog_post = BlogPost.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @blog_post }
    end
  end

  def edit
    @blog_post = BlogPost.find(params[:id])
  end

  def create
    @blog_post = BlogPost.new(params[:blog_post])
		@blog_post.user_id = current_user.id

    respond_to do |format|
      if @blog_post.save
        flash[:notice] = 'BlogPost was successfully created.'
        format.html { redirect_to(@blog_post) }
        format.xml  { render :xml => @blog_post, :status => :created, :location => @blog_post }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @blog_post.errors, :status => :unprocessable_entity }
      end
    end
  end

  def update
    @blog_post = BlogPost.find(params[:id])

    respond_to do |format|
      if @blog_post.update_attributes(params[:blog_post])
        flash[:notice] = 'BlogPost was successfully updated.'
        format.html { redirect_to(@blog_post) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @blog_post.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    @blog_post = BlogPost.find(params[:id])
    @blog_post.destroy

		flash[:notice] = 'The blog post has been deleted'

    respond_to do |format|
      format.html { redirect_to(blog_posts_url) }
      format.xml  { head :ok }
    end
  end

	private
		def require_admin
			if !current_user || !current_user.admin?
				flash[:notice] = 'You must be an admin to view this page'
				redirect_to blog_posts_path
				return false
			end
			
			return true
		end
end