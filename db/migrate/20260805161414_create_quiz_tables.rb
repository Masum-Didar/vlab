class CreateQuizTables < ActiveRecord::Migration[8.1]
  def change
    create_table :master_quizzes do |t|
      t.references :school, foreign_key: true
      t.references :experiment, null: false, foreign_key: true
      t.references :phase_step, null: false, foreign_key: true
      t.text :question, null: false
      t.string :question_type, null: false, default: "mcq"
      t.jsonb :options, default: [], null: false
      t.string :correct_answer, null: false
      t.integer :points, default: 10, null: false
      t.timestamps
    end

    create_table :assignment_quizzes do |t|
      t.references :school, foreign_key: true
      t.references :assignment, null: false, foreign_key: true
      t.references :master_quiz, null: false, foreign_key: true
      t.timestamps
    end

    create_table :quiz_logs do |t|
      t.references :school, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.references :assignment, null: false, foreign_key: true
      t.references :master_quiz, null: false, foreign_key: true
      t.text :student_answer
      t.boolean :is_correct, default: false, null: false
      t.integer :attempt_number, default: 1, null: false
      t.timestamps
    end
  end
end
