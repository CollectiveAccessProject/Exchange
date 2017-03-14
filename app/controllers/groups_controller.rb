class GroupsController < ApplicationController
  before_filter :authenticate_user!

  respond_to :html, :json
  before_action :set_group, only: [:edit, :update, :destroy]

  # GET /groups
  # GET /groups.json
  def show
    @groups = Group.where({user_id: current_user.id})
  end

  def index
    @groups = Group.where({user_id: current_user.id})
    respond_to do |format|
      format.html { render :show }
      format.json { render :show }
    end
  end

  # GET /groups/new
  def new
    @group = Group.new
  end

  # GET /groups/1/edit
  def edit
    respond_to do |format|
    if (@group.user_id != current_user.id)
      format.html { redirect_to @group, notice: 'Invalid group.' }
      format.json { render json: ["Invalid group"], status: :unprocessable_entity }
    end
    format.html { render :edit }
    format.json { render :edit }
    end

  end

  # POST /groups
  # POST /groups.json
  def create
    @group = Group.new(group_params)
    @group.user_id = current_user.id

    respond_to do |format|
      if @group.save
        format.html { redirect_to @group, notice: 'Group was created.' }
        format.json { render :index, status: :created, location: @group }
      else
        format.html { render :new }
        format.json { render json: @group.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /groups/1
  # PATCH/PUT /groups/1.json
  def update
    respond_to do |format|

      if (@group.user_id != current_user.id)
        format.html { redirect_to @group, notice: 'Invalid group.' }
        format.json { render json: ["Invalid group"], status: :unprocessable_entity }
      else

        if @group.update(group_params)
          format.html { redirect_to @group, notice: 'Group was updated.' }
          format.json { render :index, status: :ok, location: @group }
        else
          format.html { render :edit }
          format.json { render json: @group.errors, status: :unprocessable_entity }
        end
      end

    end
  end

  # DELETE /groups/1
  # DELETE /groups/1.json
  def destroy
    @group.destroy
    respond_to do |format|
      format.html { redirect_to groups_url, notice: 'Group was deleted.' }
      format.json { head :no_content }
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_group
    @group = Group.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def group_params
    params.require(:group).permit(:name, :slug, :description, :group_type)
  end
end
