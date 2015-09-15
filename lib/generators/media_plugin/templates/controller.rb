class ReplaceMeController < ApplicationController
  include SourceableController
  skip_before_action :verify_authenticity_token

  # POST /replace_mes
  # POST /replace_mes.json
  def create
    @replace_me = ReplaceMe.new(replace_me_params)

    respond_to do |format|
      if save_and_set_session @replace_me
        format.html { redirect_to :back, notice: 'Please fill out the media file information below' }
      else
        format.html { redirect_to :back, notice: 'There was a problem with the ReplaceMe' }
      end
    end
  end

  private
    # Never trust parameters from the scary internet, only allow the white list through.
    def replace_me_params
      params.require(:replace_me).permit(
                                     # @todo: add your params here!
      )
    end
end
