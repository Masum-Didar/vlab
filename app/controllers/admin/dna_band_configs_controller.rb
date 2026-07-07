class Admin::DnaBandConfigsController < Admin::BaseController
  before_action :set_experiment
  before_action :set_config, only: [:edit, :update, :destroy]

  def index
    @configs = @experiment.dna_band_configs.order(:well_number)
    @config = DnaBandConfig.new
  end

  def create
    @config = @experiment.dna_band_configs.new(config_params)
    if @config.save
      redirect_to admin_experiment_dna_band_configs_path(@experiment), notice: "Band config created."
    else
      @configs = @experiment.dna_band_configs.order(:well_number)
      render :index, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @config.update(config_params)
      redirect_to admin_experiment_dna_band_configs_path(@experiment), notice: "Band config updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @config.destroy
    redirect_to admin_experiment_dna_band_configs_path(@experiment), notice: "Band config deleted."
  end

  private

  def set_experiment
    @experiment = Experiment.find(params[:experiment_id])
  end

  def set_config
    @config = @experiment.dna_band_configs.find(params[:id])
  end

  def config_params
    params.require(:dna_band_config).permit(:sample_name, :well_number, :correct_genotype, band_positions: [])
  end
end
