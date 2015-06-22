class ResourcesController < ApplicationController
  def show
    @resource = Resource.find(params[:id])
  end

  def new

  end

  def create
    resource = Resource.new(params.require(:resource).permit(:title, :subtitle, :slug))
    resource.users_id = 1;
    resource.resource_type = 'MEOW'
    resource.source_type = "ARF"
    resource.copyright_notes = ''
    resource.transition = 0
    resource.lock_version = 0
    resource.save();

    redirect_to resource
  end
end
