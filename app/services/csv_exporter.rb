require 'csv'

class CsvExporter
  def self.export_progress(students)
    CSV.generate(headers: true) do |csv|
      csv << [
        "Student Name",
        "Email",
        "Classrooms",
        "Experiment Assigned",
        "Current Phase Location",
        "Phases Completed Count",
        "Total Phases",
        "Session Status",
        "Total Mistakes/Errors Logged",
        "Last Activity Timestamp"
      ]

      students.each do |student|
        sessions = LabSession.where(user: student).includes(:experiment)
        
        if sessions.any?
          sessions.each do |session|
            error_count = LabActivityLog.where(user: student, lab_session: session, is_error: true).count
            
            csv << [
              student.full_name,
              student.email,
              student.classrooms.pluck(:name).join("; "),
              session.experiment.title,
              session.current_phase,
              session.completed_phases&.size || 0,
              session.experiment.experiment_phases.size,
              session.status&.titleize || "Pending",
              error_count,
              session.updated_at.strftime('%Y-%m-%d %H:%M:%S')
            ]
          end
        else
          # Still include the student even if they haven't started any session
          csv << [
            student.full_name,
            student.email,
            student.classrooms.pluck(:name).join("; "),
            "None",
            "N/A",
            0,
            0,
            "N/A",
            0,
            "N/A"
          ]
        end
      end
    end
  end
end
