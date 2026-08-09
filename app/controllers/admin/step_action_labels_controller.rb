class Admin::StepActionLabelsController < Admin::BaseController
  before_action :set_step_action

  def new
    @step_action_label = @step_action.step_action_labels.new
  end

  def create
    @step_action_label = @step_action.step_action_labels.new(step_action_label_params)
    if @step_action_label.save
      redirect_to admin_step_action_path(@step_action), notice: "Label added"
    else
      redirect_to admin_step_action_path(@step_action), alert: "Failed to add label: #{@step_action_label.errors.full_messages.join(', ')}"
    end
  end

  private

  def set_step_action
    @step_action = StepAction.find(params[:step_action_id])
  end

  def step_action_label_params
    params.require(:step_action_label).permit(:label_text, :correct_match, :image_url, :position, :equipment_id)
  end
end
