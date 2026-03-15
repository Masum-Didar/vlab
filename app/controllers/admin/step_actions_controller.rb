class Admin::StepActionsController < Admin::BaseController
  before_action :set_step_action, only: [:edit, :update, :destroy]

  def index
    @step_actions = StepAction.order(:position)
  end

  def new
    @step_action = StepAction.new
  end

  def create
    @step_action = StepAction.new(step_action_params)

    if @step_action.save
      redirect_back fallback_location: admin_experiments_path,
                    notice: "Action created"
    else
      redirect_back fallback_location: admin_experiments_path,
                    alert: "Failed to create action"
    end

  end

  def edit
  end

  def update
    if @step_action.update(step_action_params)
      redirect_back fallback_location: admin_experiments_path,
                    notice: "Action updated successfully"
    else
      redirect_back fallback_location: admin_experiments_path,
                    alert: @step_action.errors.full_messages.to_sentence
    end
  end

  def destroy
    @step_action.destroy

    redirect_back fallback_location: admin_experiments_path,
                  notice: "Action deleted successfully"
  end

  private

  def set_step_action
    @step_action = StepAction.find(params[:id])
  end

  def step_action_params
    params.require(:step_action).permit(
      :phase_step_id,
      :action_type,
      :instruction,
      :position
    )
  end
end