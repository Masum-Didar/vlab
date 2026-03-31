class Admin::StepActionTransfersController < Admin::BaseController
  before_action :set_step_action

  def new
    @step_action_transfer = @step_action.step_action_transfers.new
  end

  def create
    @step_action_transfer = @step_action.step_action_transfers.new(step_action_transfer_params)
    if @step_action_transfer.save
      redirect_to admin_step_action_path(@step_action), notice: "Transfer added"
    else
      render :new
    end
  end

  private

  def set_step_action
    @step_action = StepAction.find(params[:step_action_id])
  end

  def step_action_transfer_params
    params.require(:step_action_transfer).permit(:source_container_id, :target_container_id, :chemical_id, :volume)
  end
end