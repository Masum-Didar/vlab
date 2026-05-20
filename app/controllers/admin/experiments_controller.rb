class Admin::ExperimentsController < Admin::BaseController
  before_action :set_experiment, only: [:show, :edit, :update, :destroy]

  def index
    @experiments = Experiment.includes(experiment_phases: { phase_steps: :step_actions }).order(created_at: :desc)
  end

  def show
  end

  def new
    @experiment = Experiment.new
    @experiment.status = :pending
    @experiment.published = false
    build_default_flow
  end

  def create
    @experiment = Experiment.new(experiment_params)

    if @experiment.save
      redirect_to admin_experiments_path, notice: "Experiment created successfully!"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    build_default_flow
  end

  def update
    if @experiment.update(experiment_params)
      redirect_to admin_experiments_path, notice: "Experiment updated!"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @experiment.destroy
    redirect_to admin_experiments_path, alert: "Experiment removed!"
  end

  private

  def set_experiment
    @experiment = Experiment.includes(experiment_phases: { phase_steps: :step_actions }).find(params[:id])
  end

  def experiment_params
    params.require(:experiment).permit(
      :title,
      :description,
      :method_description,
      :difficulty,
      :status,
      :duration,
      :published,
      experiment_phases_attributes: [
        :id,
        :title,
        :description,
        :position,
        :_destroy,
        experiment_steps_attributes: [
          :id,
          :instruction,
          :step_number,
          :_destroy
        ],
        phase_steps_attributes: [
          :id,
          :step_number,
          :position,
          :instruction,
          :timer_duration,
          :completion_criteria,
          :_destroy,
          step_actions_attributes: [
            :id,
            :action_type,
            :instruction,
            :position,
            :_destroy,
            { config: {} }
          ]
        ]
        # phase_items_attributes: [
        #   :id,
        #   :title,
        #   :description,
        #   :position,
        #   :_destroy
        # ]
      ]
    )
  end

  def build_default_flow
    if @experiment.experiment_phases.empty?
      phase = @experiment.experiment_phases.build(position: 1, title: "Phase 1")
      step = phase.phase_steps.build(step_number: 1, position: 1)
      step.step_actions.build(action_type: :instruction, position: 1)
    else
      @experiment.experiment_phases.each do |phase|
        if phase.phase_steps.empty?
          next_step_number = phase.phase_steps.size + 1
          step = phase.phase_steps.build(step_number: next_step_number, position: next_step_number)
          step.step_actions.build(action_type: :instruction, position: 1)
          next
        end

        phase.phase_steps.each do |step|
          step.step_actions.build(action_type: :instruction, position: 1) if step.step_actions.empty?
        end
      end
    end
  end
end
