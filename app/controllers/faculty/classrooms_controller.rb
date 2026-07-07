require "csv"

class Faculty::ClassroomsController < Faculty::BaseController
  before_action :set_classroom, only: [:show, :add_student, :remove_student, :import_students, :add_by_email]

  def index
    @classrooms = Classroom.where(school: current_user.school).order(:name)
  end

  def show
    @available_students = User.where(school: current_user.school, role: :student)
                              .where.not(id: @classroom.student_ids)
                              .order(:first_name)
  end

  def new
    @classroom = Classroom.new
  end

  def create
    @classroom = Classroom.new(classroom_params)
    @classroom.school = current_user.school

    if @classroom.save
      redirect_to faculty_classrooms_path, notice: "Classroom created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def add_student
    student = User.find(params[:student_id])

    if @classroom.students << student
      redirect_to faculty_classroom_path(@classroom), notice: "#{student.full_name} added."
    else
      redirect_to faculty_classroom_path(@classroom), alert: "Could not add student."
    end
  end

  def import_students
    file = params[:file]
    unless file
      return redirect_to faculty_classroom_path(@classroom), alert: "Please select a file."
    end

    added = 0
    created = 0
    errors = []

    case File.extname(file.original_filename).downcase
    when ".csv"
      CSV.foreach(file.path, headers: true) do |row|
        email = row["email"]&.strip&.downcase
        next if email.blank?
        student = User.find_by(school: current_user.school, role: :student, email: email)

        unless student
          student = User.new(
            email: email,
            first_name: row["first_name"]&.strip,
            last_name: row["last_name"]&.strip,
            role: :student,
            school: current_user.school,
            password: SecureRandom.hex(8)
          )
          if student.save
            created += 1
          else
            errors << "#{email}: #{student.errors.full_messages.join(', ')}"
            next
          end
        end

        begin
          @classroom.students << student unless @classroom.student_ids.include?(student.id)
          added += 1
        rescue ActiveRecord::RecordInvalid
          errors << "#{email}: already in classroom"
        end
      end
    when ".xlsx"
      sheet = Roo::Spreadsheet.open(file.path)
      sheet.each(email: "email") do |row|
        email = row[:email]&.strip&.downcase
        next if email.blank? || email == "email"
        student = User.find_by(school: current_user.school, role: :student, email: email)

        unless student
          student = User.new(
            email: email,
            first_name: row[:first_name]&.strip,
            last_name: row[:last_name]&.strip,
            role: :student,
            school: current_user.school,
            password: SecureRandom.hex(8)
          )
          if student.save
            created += 1
          else
            errors << "#{email}: #{student.errors.full_messages.join(', ')}"
            next
          end
        end

        begin
          @classroom.students << student unless @classroom.student_ids.include?(student.id)
          added += 1
        rescue ActiveRecord::RecordInvalid
          errors << "#{email}: already in classroom"
        end
      end
    else
      return redirect_to faculty_classroom_path(@classroom), alert: "Unsupported file format. Use .csv or .xlsx."
    end

    parts = ["#{added} student(s) added."]
    parts << "#{created} new account(s) created." if created > 0
    parts << "Errors: #{errors.join(', ')}" if errors.any?
    redirect_to faculty_classroom_path(@classroom), notice: parts.join(" ")
  end

  def add_by_email
    email = params[:email]&.strip&.downcase
    return redirect_to faculty_classroom_path(@classroom), alert: "Email is required." if email.blank?

    student = User.find_by(school: current_user.school, role: :student, email: email)

    unless student
      student = User.new(
        email: email,
        role: :student,
        school: current_user.school,
        password: SecureRandom.hex(8)
      )
      unless student.save
        return redirect_to faculty_classroom_path(@classroom), alert: "Could not create account: #{student.errors.full_messages.join(', ')}"
      end
    end

    if @classroom.student_ids.include?(student.id)
      redirect_to faculty_classroom_path(@classroom), notice: "#{student.full_name} is already in this classroom."
    else
      @classroom.students << student
      redirect_to faculty_classroom_path(@classroom), notice: "#{student.full_name} added."
    end
  end

  def download_template
    csv = CSV.generate(headers: true) do |rows|
      rows << %w[email first_name last_name]
      rows << ["student@example.com", "John", "Doe"]
      rows << ["another@example.com", "Jane", "Smith"]
    end

    send_data csv, filename: "student_import_template.csv", type: "text/csv"
  end

  def remove_student
    membership = @classroom.classroom_memberships.find_by(user_id: params[:student_id])

    if membership&.destroy
      redirect_to faculty_classroom_path(@classroom), notice: "Student removed."
    else
      redirect_to faculty_classroom_path(@classroom), alert: "Could not remove student."
    end
  end

  private

  def set_classroom
    @classroom = Classroom.where(school: current_user.school).find(params[:id])
  end

  def classroom_params
    params.require(:classroom).permit(:name, :description)
  end
end
