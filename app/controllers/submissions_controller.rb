class SubmissionsController < ApplicationController
  before_action :authenticate_user!

  before_action :set_submission, only: %i[ show edit update destroy ]

  def index
    @submissions = Submission.all
  end

  def show; end

  def new
    @submission = Submission.new
  end

  def create
    @submission = Submission.new(submission_params)
    if @submission.save
      redirect_to @submission, notice: "Submission created."
    else
      render :new
    end
  end

  def edit; end

  def update
    if @submission.update(submission_params)
      redirect_to @submission, notice: "Submission updated."
    else
      render :edit
    end
  end

  def destroy
    @submission.destroy
    redirect_to submissions_path, notice: "Submission deleted."
  end

  private

  def set_submission
    @submission = Submission.find(params[:id])
  end

  def submission_params
    params.require(:submission).permit(:user_id, :experiment_id, :status, :data)
  end
end
