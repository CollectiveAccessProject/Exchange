class FeaturedController < ApplicationController
  def index
    @featured_content_sets = FeaturedContentSet.where(access: 1)
    @slug = params[:slug]
    if(!@slug)
    	@featured_content_sets.each do |s|
			@slug = s.slug
			break
		end
    end
    if(@slug)
    	@set = FeaturedContentSet.where(access: 1, slug: @slug).first
    	if(!@set)
    		@set = FeaturedContentSet.where(access: 1, id: @slug).first
    	end
    	if(@set)
    		@set_items = @set.featured_content_set_items
    		@id=@set.id
    	end
    end
  end

  def get_set_contents
    resp = {status: :ok}

    # get current ranks for media
    set = FeaturedContentSet.where(access: 1, id: params[:id]).first

    if(!set)
      raise StandardError, "Invalid set"
    end

    set_items = set.featured_content_set_items

    resp['html'] = render_to_string('featured/_set_item_list', locals: { set: set, items: set_items }, layout: false)


    respond_to do |format|
      format.json { render :json => resp }
    end
  end
end