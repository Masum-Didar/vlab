class ExperimentsController < ApplicationController
  before_action :authenticate_user!

  def index
    @experiments = Experiment.all
  end

  def show
  end

  def lab
  end
end
