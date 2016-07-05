class ResourceHierarchiesController < ApplicationController

  before_filter :authenticate_user!
  before_action :set_resource_hierarchy, only: [:destroy]


  def destroy
    @resource = @resource_hierarchy.resource

    #
    # TODO: Is user allowed to do this?
    #
    @resource_hierarchy.destroy
    respond_to do |format|
      format.html { redirect_to edit_resource_path(@resource), notice: 'Child was removed.' }
      format.json { head :no_content }
      format.js
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_resource_hierarchy
    @resource_hierarchy = ResourceHierarchy.find(params[:id])
  end
end