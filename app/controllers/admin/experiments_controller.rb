class Admin::ExperimentsController < Admin::BaseController
  before_action :set_experiment, only: [:show, :edit, :update, :destroy]

  def index
    @experiments = Experiment.order(created_at: :desc)
  end

  def show
  end

  def new
    @experiment = Experiment.new

    # Build at least one phase
    phase = @experiment.experiment_phases.build

    # Build one step inside phase
    phase.phase_steps.build
    # phase.experiment_steps.build
    #
    # # Build one phase item inside phase
    # phase.phase_items.build
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
    # Ensure existing phases have at least one step & item for rendering
    @experiment.experiment_phases.each do |phase|
      phase.phase_steps.build if phase.phase_steps.empty?

      # phase.experiment_steps.build if phase.experiment_steps.empty?
      # phase.phase_items.build if phase.phase_items.empty?
    end
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
    @experiment = Experiment.find(params[:id])
  end

  def experiment_params
    params.require(:experiment).permit(
      :title,
      :description,
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
          :instruction,
          :_destroy
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
end