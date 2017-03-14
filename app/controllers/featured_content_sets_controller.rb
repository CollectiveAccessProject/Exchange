class FeaturedContentSetsController < ApplicationController
  before_filter :authenticate_user!
  before_action :verify_access

  respond_to :html, :json

  # UI autocomplete on resource title (used by related resources lookup)
  autocomplete :resource, :title, :full => true, :extra_data => [:id, :collection_identifier, :resource_type], :display_value => :get_autocomplete_label


  def verify_access
    raise StandardError, "Not allowed" if (!current_user.has_role? :admin)
  end

  def index
    # list all feature content sets
    @featured_content_sets = FeaturedContentSet.all().order("rank")
  end

  def new
    @featured_content_set = FeaturedContentSet.new
  end

  def create
    @featured_content_set = FeaturedContentSet.new(featured_content_set_params)
    # @featured_content_set.user = current_user

    respond_to do |format|
      if @featured_content_set.save

        format.html { redirect_to edit_featured_content_set_path(@featured_content_set), notice: 'Featured content set has been added.' }
        format.json { render :index, status: :created, location: @featured_content_set }
      else
        format.html { render :new }
        format.json { render json: @featured_content_set.errors, status: :unprocessable_entity }
      end
    end
  end


  def edit
    @featured_content_set = FeaturedContentSet.find(params[:id])
  end

  def update
    @featured_content_set = FeaturedContentSet.find(params[:id])

    @featured_content_set.update(featured_content_set_params)

    respond_to do |format|
      if (@featured_content_set.save)
        format.html { redirect_to edit_featured_content_set_path(@featured_content_set), notice:  'Featured content set has been updated.' }
      else
        format.html { redirect_to edit_featured_content_set_path(@featured_content_set), notice:  'Changes could not be saved: ' + @featured_content_set.errors.full_messages.join("; ") }
      end
    end

  end

  def destroy
    @featured_content_set = FeaturedContentSet.find(params[:id])
    title = @featured_content_set.title

    respond_to do |format|
      @featured_content_set.destroy
      format.html { redirect_to featured_content_sets_path, notice: ActionController::Base.helpers.sanitize('Featured content set ' + title + ' has been removed.') }

    end
  end

  #
  # Add set item
  #
  def add_set_item
    begin
      @featured_content_set = FeaturedContentSet.find(params[:id])

      to_resource_id = params[:to_resource_id]
      item = FeaturedContentSetItem.where(featured_content_set_id: @featured_content_set.id, resource_id: to_resource_id, title: params[:title], subtitle: params[:subtitle]).first_or_create

      resp = {:status => :ok, :html => render_to_string("featured_content_sets/_item_list", layout: false)}
    rescue StandardError => ex
      resp = {:status => :err, :error => ex.message}
    end

    respond_to do |format|
      format.json { render :json => resp, status: :ok }
    end

  end

  #
  #
  #
  def remove_set_item
    begin
      @featured_content_set = FeaturedContentSet.find(params[:id])
      resource_id = params[:related]
      FeaturedContentSetItem.where(featured_content_set_id: @featured_content_set.id, resource_id: resource_id).destroy_all

      resp = {:status => :ok, :html => render_to_string("featured_content_sets/_item_list", layout: false)}
    rescue StandardError => ex
      resp = {:status => :err, :error => ex.message}
    end

    respond_to do |format|
      format.json { render :json => resp }
    end
  end

  # set order of set items
  def set_item_order
    resp = {status: :ok}

    # get current ranks for set items
    current_items = FeaturedContentSetItem.where(featured_content_set_id: params[:id]).order(:rank)
    ranks = current_items.pluck(:rank)

    params[:ranks].each do |id|
      if (i = FeaturedContentSetItem.where(featured_content_set_id: params[:id], resource_id: id).first)
        i.rank = ranks.shift
        if (!i.save)
          resp = {:status => :err, :error => i.errors.full_messages.join('; ')}
          break
        end
      end
    end

    respond_to do |format|
      format.json { render :json => resp }
    end
  end

  # set order of sets
  def set_order
    resp = {status: :ok}

    # get current ranks for sets
    current_items = FeaturedContentSet.order(:rank)
    ranks = current_items.pluck(:rank)

    r = 1
    params[:ranks].each do |id|
      if (i = FeaturedContentSet.find(id))
        i.rank = r
        r = r + 1
        if (!i.save)
          resp = {:status => :err, :error => i.errors.full_messages.join('; ')}
          break
        end
      end
    end

    respond_to do |format|
      format.json { render :json => resp }
    end
  end


  def featured_content_set_params
    params.require(:featured_content_set).permit(
        :title, :slug, :subtitle, :body_text, :access
    )
  end
end