
class BlogPost < ActiveRecord::Base
	include BlogKitModelHelper
	
	unloadable
	
	belongs_to :user
	
	has_many :blog_comments, :dependent => :destroy
	has_many :blog_images, :dependent => :destroy
	
	accepts_nested_attributes_for :blog_images, :allow_destroy => true
	
	
	validates_presence_of :title
	validates_presence_of :body

  	default_scope :order => 'published_at DESC'
	
	scope :published, { :conditions => {:published => 1 }}
	scope :drafts, { :conditions => {:published => 0 }}
	
	before_save :check_published, :if => :not_resaving?
	after_save :replace_blog_image_tags, :if => :not_resaving?

	acts_as_taggable

	def not_resaving?
		!@resaving
	end
	
	# For images that haven't been uploaded yet, they get a random image id
	# with 'upload' infront of it.  We replace those with their new image
	# id
	def replace_blog_image_tags
		@resaving = true
		self.body.gsub!(/[{]blog_image:upload[0-9]+:[a-zA-Z]+[}]/) do |image_tag|
			random_id, size = image_tag.scan(/upload([0-9]+)[:]([a-zA-Z]+)/).flatten
			
			new_id = random_id
			
			matching_image = self.blog_images.reject {|bi| !bi.random_id || bi.random_id != random_id }.first
			
			if matching_image
				new_id = matching_image.id
			end
			
			"{blog_image:#{new_id}:#{size}}"
		end
		
		self.save
		@resaving = false
		
		return true
	end
	
	def check_published
		if self.published_change && self.published_change == [false, true]
			# Moved to published state, update published_on
			self.published_at = Time.now
		end
	end
	
	def show_user?
		(!BlogKit.instance.settings['show_user_who_published'] || BlogKit.instance.settings['show_user_who_published'] == true) && self.user
	end
	
	
	def user_name(skip_link=false)
		if !skip_link && BlogKit.instance.settings['link_to_user']
			return "<a href=\"/users/#{self.user.id}\">#{CGI.escapeHTML(self.user.name)}</a>"
		else
			return self.user.name
		end
	end

	def parsed_body
		image_parsed_body = self.body.gsub(/[{]blog_image[:]([0-9]+)[:]([a-zA-Z]+)[}]/) do |str|
			puts "IMAGE ID: #{$1.to_i}"
			img = BlogImage.find_by_id($1.to_i)
			
			if img
				img.image.url($2)
			else
				''
			end
		end
		
		return code_highlight_and_markdown(image_parsed_body)
	end
	
	def formatted_updated_at
		self.updated_at.strftime(BlogKit.instance.settings['post_date_format'] || '%m/%d/%Y at %I:%M%p')
	end
	
	# Provide SEO Friendly URL's
	def to_param
    "#{id}-#{title.gsub(/[^a-z0-9]+/i, '-')}"
  end
end
