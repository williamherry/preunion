class MissionsController < ApplicationController
  before_action :load_mission, only: [:create]
  load_and_authorize_resource

  def index
    @events = Event.order("id desc").limit(15)
  end

  def show
    @latest_missions = Mission.order("id desc").limit(10)
  end

  def create
    @mission = Mission.new(mission_params)
    @mission.creator = current_user
    @mission.status = 0

    if @mission.save
      @mission.events.create(user: current_user, action: "create")
      redirect_to @mission, notice: t('common.create_success')
    else
      render action: 'new'
    end
  end

  def edit
    unless current_user == @mission.creator
      redirect_to missions_path, notice: t("error.require_permission")
    end
  end

  def update
    if current_user == @mission.creator && @mission.update(mission_params)
      redirect_to @mission, notice: t('common.update_success')
    else
      render action: 'edit', notice: t('common.update_not_success')
    end
  end

  def perform_action
    if @mission.perform_action(params[:action_name], current_user)
      @mission.events.create(user: current_user, action: params[:action_name])
      redirect_to :back, notice: t("missions.#{params[:action_name]}_success")
    else
      redirect_to :back, notice: t("missions.#{params[:action_name]}_fail")
    end

  end

  private

    def mission_params
      params.require(:mission).permit(:name, :description, :status)
    end

    def load_mission
      @mission = Mission.new(mission_params)
    end

end
