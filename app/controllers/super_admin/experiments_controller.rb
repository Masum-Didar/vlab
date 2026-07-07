class SuperAdmin::ExperimentsController < SuperAdmin::BaseController
  def index
    @experiments = Experiment.order(:title)
    @schools = School.order(:name)
  end
end
