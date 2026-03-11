# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_03_03_095510) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "chemicals", force: :cascade do |t|
    t.string "color_hex"
    t.datetime "created_at", null: false
    t.text "description"
    t.string "formula"
    t.string "name"
    t.jsonb "properties"
    t.string "state"
    t.datetime "updated_at", null: false
  end

  create_table "departments", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name"
    t.bigint "school_id", null: false
    t.datetime "updated_at", null: false
    t.index ["school_id"], name: "index_departments_on_school_id"
  end

  create_table "equipment", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "equipment_type"
    t.string "name"
    t.datetime "updated_at", null: false
  end

  create_table "experiment_chemicals", force: :cascade do |t|
    t.bigint "chemical_id", null: false
    t.datetime "created_at", null: false
    t.bigint "experiment_id", null: false
    t.integer "quantity_default"
    t.datetime "updated_at", null: false
    t.index ["chemical_id"], name: "index_experiment_chemicals_on_chemical_id"
    t.index ["experiment_id"], name: "index_experiment_chemicals_on_experiment_id"
  end

  create_table "experiment_equipments", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "equipment_id", null: false
    t.bigint "experiment_id", null: false
    t.datetime "updated_at", null: false
    t.index ["equipment_id"], name: "index_experiment_equipments_on_equipment_id"
    t.index ["experiment_id"], name: "index_experiment_equipments_on_experiment_id"
  end

  create_table "experiment_phases", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.bigint "experiment_id", null: false
    t.integer "position"
    t.string "title"
    t.datetime "updated_at", null: false
    t.index ["experiment_id"], name: "index_experiment_phases_on_experiment_id"
  end

  create_table "experiment_results", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.jsonb "data"
    t.bigint "experiment_id", null: false
    t.bigint "school_id"
    t.integer "status"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["experiment_id"], name: "index_experiment_results_on_experiment_id"
    t.index ["school_id"], name: "index_experiment_results_on_school_id"
    t.index ["user_id"], name: "index_experiment_results_on_user_id"
  end

  create_table "experiment_steps", force: :cascade do |t|
    t.boolean "allow_multiple", default: false
    t.jsonb "config", default: {}
    t.datetime "created_at", null: false
    t.jsonb "expected_action"
    t.bigint "experiment_id", null: false
    t.bigint "experiment_phase_id", null: false
    t.text "instruction"
    t.integer "points", default: 100
    t.integer "step_number"
    t.string "step_type", default: "observation_input"
    t.datetime "updated_at", null: false
    t.index ["experiment_id"], name: "index_experiment_steps_on_experiment_id"
    t.index ["experiment_phase_id"], name: "index_experiment_steps_on_experiment_phase_id"
  end

  create_table "experiments", force: :cascade do |t|
    t.jsonb "config"
    t.datetime "created_at", null: false
    t.text "description"
    t.integer "difficulty"
    t.integer "duration", default: 0
    t.boolean "published"
    t.bigint "school_id"
    t.integer "status", default: 0, null: false
    t.string "title"
    t.datetime "updated_at", null: false
    t.index ["school_id"], name: "index_experiments_on_school_id"
  end

  create_table "lab_sessions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "ended_at"
    t.bigint "experiment_id", null: false
    t.bigint "school_id"
    t.datetime "started_at"
    t.integer "status"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["experiment_id"], name: "index_lab_sessions_on_experiment_id"
    t.index ["school_id"], name: "index_lab_sessions_on_school_id"
    t.index ["user_id"], name: "index_lab_sessions_on_user_id"
  end

  create_table "phase_items", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.bigint "experiment_phase_id", null: false
    t.integer "position"
    t.string "title"
    t.datetime "updated_at", null: false
    t.index ["experiment_phase_id"], name: "index_phase_items_on_experiment_phase_id"
  end

  create_table "schools", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "domain"
    t.string "name"
    t.string "subdomain"
    t.datetime "updated_at", null: false
    t.index ["subdomain"], name: "index_schools_on_subdomain", unique: true
  end

  create_table "step_options", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "experiment_step_id", null: false
    t.boolean "is_correct"
    t.text "label"
    t.string "option_type"
    t.string "option_value"
    t.integer "position"
    t.datetime "updated_at", null: false
    t.index ["experiment_step_id"], name: "index_step_options_on_experiment_step_id"
  end

  create_table "submissions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.jsonb "data"
    t.bigint "experiment_id", null: false
    t.bigint "school_id"
    t.integer "status"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["experiment_id"], name: "index_submissions_on_experiment_id"
    t.index ["school_id"], name: "index_submissions_on_school_id"
    t.index ["user_id"], name: "index_submissions_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "department_id"
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "first_name"
    t.string "last_name"
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.integer "role", default: 0
    t.bigint "school_id"
    t.datetime "updated_at", null: false
    t.index ["department_id"], name: "index_users_on_department_id"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["school_id"], name: "index_users_on_school_id"
  end

  add_foreign_key "departments", "schools"
  add_foreign_key "experiment_chemicals", "chemicals"
  add_foreign_key "experiment_chemicals", "experiments"
  add_foreign_key "experiment_equipments", "equipment"
  add_foreign_key "experiment_equipments", "experiments"
  add_foreign_key "experiment_phases", "experiments"
  add_foreign_key "experiment_results", "experiments"
  add_foreign_key "experiment_results", "schools"
  add_foreign_key "experiment_results", "users"
  add_foreign_key "experiment_steps", "experiment_phases"
  add_foreign_key "experiment_steps", "experiments"
  add_foreign_key "experiments", "schools"
  add_foreign_key "lab_sessions", "experiments"
  add_foreign_key "lab_sessions", "schools"
  add_foreign_key "lab_sessions", "users"
  add_foreign_key "phase_items", "experiment_phases"
  add_foreign_key "step_options", "experiment_steps"
  add_foreign_key "submissions", "experiments"
  add_foreign_key "submissions", "schools"
  add_foreign_key "submissions", "users"
  add_foreign_key "users", "departments"
  add_foreign_key "users", "schools"
end
