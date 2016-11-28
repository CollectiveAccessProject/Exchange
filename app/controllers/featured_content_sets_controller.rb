class FeaturedContentSetsController < ApplicationController
  before_filter :authenticate_user!
  before_action :verify_access

  respond_to :html, :json

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

  def featured_content_set_params
    params.require(:featured_content_set).permit(
        :title, :slug, :subtitle, :body_text, :access
    )
  end
end