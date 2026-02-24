class Admin::ExperimentsController < Admin::BaseController

  def index
    @experiments = Experiment.order(created_at: :desc)
  end

  def show
    @experiment = Experiment.find(params[:id])
  end

  def new
    @experiment = Experiment.new
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
    @experiment = Experiment.find(params[:id])
  end

  def update
    @experiment = Experiment.find(params[:id])
    if @experiment.update(experiment_params)
      redirect_to admin_experiments_path, notice: "Experiment updated!"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @experiment = Experiment.find(params[:id])
    @experiment.destroy
    redirect_to admin_experiments_path, alert: "Experiment removed!"
  end

  private

  # def experiment_params
  #   params.require(:experiment).permit(
  #     :title,
  #     :description,
  #     :difficulty,
  #     :status,
  #     :duration,
  #     :published
  #   )
  # end

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
        ]
      ]
    )
  end
end
