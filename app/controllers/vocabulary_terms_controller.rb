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
    @vocabulary_term = VocabularyTerm.where(ancestry: nil).order("term")
  end

  def new
    @vocabulary_term = VocabularyTerm.new
    @parent_id = params[:id]
  end

  def create
    @vocabulary_term = VocabularyTerm.new(vocabulary_term_params)
    # @vocabulary_term.user = current_user
    if (parent_id = params[:parent_id])
      puts "parent is " + parent_id
      @vocabulary_term.parent_id= parent_id
    end

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


  def add_synonym
    begin
      @vocabulary_term = VocabularyTerm.find(params[:id])

      syn = VocabularyTermSynonym.where(vocabulary_term_id: @vocabulary_term.id, synonym: params[:synonym], description: params[:description], reference_url: params[:reference_url]).first_or_create

      resp = {:status => :ok, :html => render_to_string("vocabulary_terms/_synonym_list", layout: false)}
    rescue StandardError => ex
      resp = {:status => :err, :error => ex.message}
    end

    respond_to do |format|
      format.json { render :json => resp, status: :ok }
    end

  end

  def edit_synonym
    begin
      @vocabulary_term = VocabularyTerm.find(params[:id])

      if (syn = VocabularyTermSynonym.where(vocabulary_term_id: @vocabulary_term.id, id: synonym_params[:synonym_id]).first)
        syn.update ({synonym: synonym_params[:synonym], description: synonym_params[:description], reference_url: synonym_params[:reference_url]})
      end

      resp = {:status => :ok, :html => render_to_string("vocabulary_terms/_synonym_list", layout: false)}
    rescue StandardError => ex
      resp = {:status => :err, :error => ex.message}
    end

    respond_to do |format|
      format.json { render :json => resp, status: :ok }
    end

  end

  def remove_synonym
    begin
      @vocabulary_term = VocabularyTerm.find(params[:id])
      VocabularyTermSynonym.where(vocabulary_term_id: @vocabulary_term.id, id: params[:synonym_id]).destroy_all

      resp = {:status => :ok, :html => render_to_string("vocabulary_terms/_synonym_list", layout: false)}
    rescue StandardError => ex
      resp = {:status => :err, :error => ex.message}
    end

    respond_to do |format|
      format.json { render :json => resp }
    end
  end

  def vocabulary_term_params
    params.require(:vocabulary_term).permit(
        :id, :term, :description, :reference_url
    )
  end

  def synonym_params
    params.require(:vocabulary_term_synonym).permit(
        :id, :synonym_id, :synonym, :description, :reference_url
    )
  end
end