class GroupsController < ApplicationController
  before_filter :authenticate_user!

  respond_to :html, :json
  before_action :set_group, only: [:edit, :update, :destroy, :add_user, :remove_user, :get_umich_groups_for_user]

  # UI autocomplete on user name/email (used by user lookup)
  autocomplete :user, :name, :full => true, :extra_data => [:id]


  # Override user name/email autocomplete to match on both name and email (sigh)
  def autocomplete_user_name
    term = params[:term]
    u = User.where(
        'LOWER(users.name) LIKE ? OR LOWER(users.email) LIKE ?',
        "%#{term}%", "%#{term}%"
    ).order(:id).all
    render :json => u.map { |user| {:id => user.id, :label => user.name + " (" + user.email + ")", :value => user.name + " (" + user.email + ")"} }
  end

  # GET /groups
  # GET /groups.json
  def show
    index
  end

  def index
    @groups = Group.where({user_id: current_user.id, group_type: 1})
    @umich_groups = Group.joins([:user_groups]).where({"user_groups.user_id": current_user.id, "groups.group_type": 2}).order("lower(groups.name)");
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
        format.html { redirect_to edit_group_path(@group), notice: 'Group was created.' }
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

  #
  #
  #
  def add_user
    begin
      params.permit(:to_user_id, :access_type)
      to_user_id = params[:to_user_id]
      access_type = params[:access_type]
      item = UserGroup.where(group_id: @group.id, user_id: to_user_id, access_type: access_type).first_or_create

      resp = {:status => :ok, :html => render_to_string("groups/_user_list", layout: false)}
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
  def remove_user
    begin
      user_id = params[:user_id]
      UserGroup.where(group_id: @group.id, user_id: user_id).destroy_all

      resp = {:status => :ok, :html => render_to_string("groups/_user_list", layout: false)}
    rescue StandardError => ex
      resp = {:status => :err, :error => ex.message}
    end

    respond_to do |format|
      format.json { render :json => resp }
    end
  end
  
  #
  #
  #
  def get_umich_groups_for_user
      Group.get_umich_groups_for_user(current_user)
     redirect_to "/groups/index", flash: {notice: "Reloaded groups"}
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
