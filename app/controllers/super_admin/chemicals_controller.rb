class SuperAdmin::ChemicalsController < SuperAdmin::BaseController
  before_action :set_chemical, only: [:show, :edit, :update, :destroy]

  def index
    @chemicals = Chemical.order(created_at: :desc)
  end

  def show
  end

  def new
    @chemical = Chemical.new
  end

  def create
    @chemical = Chemical.new(chemical_params)
    if @chemical.save
      redirect_to super_admin_chemicals_path, notice: "Chemical created successfully!"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @chemical.update(chemical_params)
      redirect_to super_admin_chemicals_path, notice: "Chemical updated!"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @chemical.destroy
    redirect_to super_admin_chemicals_path, alert: "Chemical removed!"
  end

  private

  def set_chemical
    @chemical = Chemical.find(params[:id])
  end

  def chemical_params
    params.require(:chemical).permit(:name, :formula, :description, :state)
  end
end
