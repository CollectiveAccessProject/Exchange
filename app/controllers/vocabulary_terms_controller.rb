class VocabularyTermsController < ApplicationController
  before_filter :authenticate_user!
  before_action :verify_access

  respond_to :html, :json

  # UI autocomplete on resource title (used by related resources lookup)
  autocomplete :resource, :title, :full => true, :extra_data => [:id, :collection_identifier, :resource_type], :display_value => :get_autocomplete_label


  def verify_access
    raise StandardError, "Not allowed" if (!current_user.has_role? :admin)
  end

  def index
    @vocabulary_term = VocabularyTerm.all().order("term")
  end

  def new
    @vocabulary_term = VocabularyTerm.new
  end

  def create
    @vocabulary_term = VocabularyTerm.new(vocabulary_term_params)
    # @vocabulary_term.user = current_user

    respond_to do |format|
      if @vocabulary_term.save

        format.html { redirect_to edit_vocabulary_term_path(@vocabulary_term), notice: 'Vocabulary term has been added.' }
        format.json { render :index, status: :created, location: @vocabulary_term }
      else
        format.html { render :new }
        format.json { render json: @vocabulary_term.errors, status: :unprocessable_entity }
      end
    end
  end


  def edit
    @vocabulary_term = VocabularyTerm.find(params[:id])
  end

  def update
    @vocabulary_term = VocabularyTerm.find(params[:id])

    @vocabulary_term.update(vocabulary_term_params)

    respond_to do |format|
      if (@vocabulary_term.save)
        format.html { redirect_to edit_vocabulary_term_path(@vocabulary_term), notice:  'Vocabulary term has been updated.' }
      else
        format.html { redirect_to edit_vocabulary_term_path(@vocabulary_term), notice:  'Changes could not be saved: ' + @vocabulary_term.errors.full_messages.join("; ") }
      end
    end

  end

  def destroy
    @vocabulary_term = VocabularyTerm.find(params[:id])
    term = @vocabulary_term.term

    respond_to do |format|
      @vocabulary_term.destroy
      format.html { redirect_to vocabulary_terms_path, notice: ActionController::Base.helpers.sanitize('Vocabulary term ' + term + ' has been removed.') }

    end
  end

  #
  # Add set item
  #
  def add_set_item
    begin
      @vocabulary_term = VocabularyTerm.find(params[:id])

      to_resource_id = params[:to_resource_id]
      item = VocabularyTermSynonym.where(featured_content_set_id: @featured_content_set.id, resource_id: to_resource_id, title: params[:title], subtitle: params[:subtitle]).first_or_create

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
      @featured_content_set = VocabularyTerm.find(params[:id])
      resource_id = params[:related]
      VocabularyTermSynonym.where(featured_content_set_id: @featured_content_set.id, resource_id: resource_id).destroy_all

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
    current_items = VocabularyTermSynonym.where(featured_content_set_id: params[:id]).order(:rank)
    ranks = current_items.pluck(:rank)

    params[:ranks].each do |id|
      if (i = VocabularyTermSynonym.where(featured_content_set_id: params[:id], resource_id: id).first)
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
    current_items = VocabularyTerm.order(:rank)
    ranks = current_items.pluck(:rank)

    r = 1
    params[:ranks].each do |id|
      if (i = VocabularyTerm.find(id))
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


  def vocabulary_term_params
    params.require(:vocabulary_term).permit(
        :term, :description, :reference_url
    )
  end
end