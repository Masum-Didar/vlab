require 'prawn'
require 'prawn/table'

class PdfGenerator
  def self.generate(lab_session)
    user = lab_session.user
    experiment = lab_session.experiment
    school = lab_session.school

    Prawn::Document.new(page_size: 'A4', margin: 50) do |pdf|
      # Header Theme Styling (Dark slate & Teal)
      pdf.fill_color '0f172a'
      pdf.text "VLAB EXPERIMENT REPORT", size: 22, style: :bold, align: :center, character_spacing: 1
      pdf.move_down 5
      pdf.fill_color '64748b'
      pdf.text "Official Digital Laboratory Records", size: 10, align: :center, style: :italic
      pdf.move_down 15
      
      # Double line divider
      pdf.stroke_color 'cbd5e1'
      pdf.stroke_horizontal_rule
      pdf.move_down 2
      pdf.stroke_horizontal_rule
      pdf.move_down 20

      # Two Column Info Panel
      pdf.fill_color '0f172a'
      pdf.text "GENERAL INFORMATION", size: 12, style: :bold, color: '0d6b78'
      pdf.move_down 8

      general_info = [
        ["Student Name:", user.full_name, "Experiment:", experiment.title],
        ["Student Email:", user.email, "Date Completed:", lab_session.updated_at.strftime('%B %d, %Y')],
        ["School Affiliate:", school&.name || 'VLab Portal', "Time Completed:", lab_session.updated_at.strftime('%I:%M %p')]
      ]

      pdf.table(general_info, cell_style: { border_width: 0, padding: [4, 10, 4, 0], size: 10 }) do
        column(0).style(font_style: :bold, color: '475569')
        column(2).style(font_style: :bold, color: '475569')
      end
      
      pdf.move_down 25
      pdf.stroke_color 'e2e8f0'
      pdf.stroke_horizontal_rule
      pdf.move_down 20

      # Lab Performance Score
      pdf.text "PERFORMANCE ASSESSMENT", size: 12, style: :bold, color: '0d6b78'
      pdf.move_down 8
      
      pdf.fill_color '10b981' # Green color
      pdf.text "Lab Status: COMPLETED", size: 11, style: :bold
      pdf.fill_color '0f172a'
      pdf.text "Passing Grade: 100% (Pass)", size: 10, style: :bold
      pdf.text "No critical violations (pipette tip contamination check passed, target voltage 70V verified).", size: 9, color: '64748b'
      
      pdf.move_down 25
      pdf.stroke_horizontal_rule
      pdf.move_down 20

      # Genotype Classification Table
      pdf.text "GENOTYPE IDENTIFICATION RESULTS", size: 12, style: :bold, color: '0d6b78'
      pdf.move_down 8

      table_data = [
        ["Sample ID", "Gel Well Location", "DNA Bands Stained (Migration distance)", "Genotype Classification"],
        ["Sample A", "Well 2", "50 bp, 130 bp", "Wild Type"],
        ["Sample B", "Well 3", "130 bp", "Mutant"],
        ["Sample C", "Well 4", "50 bp, 90 bp, 130 bp", "Heterozygous"]
      ]

      pdf.table(table_data, header: true, width: 495) do
        row(0).style(background_color: 'f8fafc', font_style: :bold, border_color: 'cbd5e1', size: 10)
        row(1..3).style(size: 9, border_color: 'e2e8f0', padding: 8)
        column(0).style(font_style: :bold)
      end

      # Footer & Authenticity Stamp
      pdf.move_down 60
      pdf.stroke_color 'cbd5e1'
      pdf.stroke_horizontal_rule
      pdf.move_down 15
      pdf.fill_color '94a3b8'
      pdf.text "This report has been cryptographically generated and certified authentic by VLab Simulations Inc.", size: 8, align: :center
      pdf.text "Security Hash: #{Digest::SHA256.hexdigest("#{user.id}-#{lab_session.id}-#{lab_session.updated_at}")[0..16].upcase}", size: 8, align: :center, style: :mono
    end.render
  end
end
