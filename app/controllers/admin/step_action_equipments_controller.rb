class Admin::StepActionEquipmentsController < Admin::BaseController
  before_action :set_step_action

  def new
    @step_action_equipment = @step_action.step_action_equipments.new
  end

  def create
    @step_action_equipment = @step_action.step_action_equipments.new(step_action_equipment_params)
    if @step_action_equipment.save
      redirect_to admin_step_action_path(@step_action), notice: "Equipment added"
    else
      render :new
    end
  end

  private

  def set_step_action
    @step_action = StepAction.find(params[:step_action_id])
  end

  def step_action_equipment_params
    params.require(:step_action_equipment).permit(:equipment_id, :quantity)
  end
end