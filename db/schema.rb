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

ActiveRecord::Schema[8.1].define(version: 2026_07_07_052945) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "assignments", force: :cascade do |t|
    t.bigint "classroom_id", null: false
    t.datetime "created_at", null: false
    t.datetime "due_date"
    t.bigint "experiment_id", null: false
    t.bigint "faculty_id", null: false
    t.bigint "school_id", null: false
    t.integer "status"
    t.datetime "updated_at", null: false
    t.index ["classroom_id"], name: "index_assignments_on_classroom_id"
    t.index ["experiment_id"], name: "index_assignments_on_experiment_id"
    t.index ["faculty_id"], name: "index_assignments_on_faculty_id"
    t.index ["school_id"], name: "index_assignments_on_school_id"
  end

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

  create_table "classroom_memberships", force: :cascade do |t|
    t.bigint "classroom_id", null: false
    t.datetime "created_at", null: false
    t.bigint "school_id", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["classroom_id", "user_id"], name: "index_classroom_memberships_on_classroom_id_and_user_id", unique: true
    t.index ["classroom_id"], name: "index_classroom_memberships_on_classroom_id"
    t.index ["school_id"], name: "index_classroom_memberships_on_school_id"
    t.index ["user_id"], name: "index_classroom_memberships_on_user_id"
  end

  create_table "classrooms", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.string "name"
    t.bigint "school_id", null: false
    t.datetime "updated_at", null: false
    t.index ["school_id"], name: "index_classrooms_on_school_id"
  end

  create_table "containers", force: :cascade do |t|
    t.string "container_type", default: "general", null: false
    t.datetime "created_at", null: false
    t.string "name"
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
    t.text "description"
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
    t.text "method_description"
    t.boolean "published"
    t.bigint "school_id"
    t.integer "status", default: 0, null: false
    t.string "title"
    t.datetime "updated_at", null: false
    t.index ["school_id"], name: "index_experiments_on_school_id"
  end

  create_table "lab_sessions", force: :cascade do |t|
    t.jsonb "completed_phases", default: []
    t.datetime "created_at", null: false
    t.integer "current_phase", default: 1, null: false
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

  create_table "phase_steps", force: :cascade do |t|
    t.string "completed_image_url"
    t.text "completion_criteria"
    t.datetime "created_at", null: false
    t.bigint "experiment_phase_id", null: false
    t.string "image_url"
    t.text "instruction"
    t.integer "position"
    t.integer "step_number"
    t.integer "timer_duration"
    t.datetime "updated_at", null: false
    t.string "video_url"
    t.index ["experiment_phase_id"], name: "index_phase_steps_on_experiment_phase_id"
  end

  create_table "schools", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "domain"
    t.string "name"
    t.string "subdomain"
    t.datetime "updated_at", null: false
    t.index ["subdomain"], name: "index_schools_on_subdomain", unique: true
  end

  create_table "step_action_equipments", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "equipment_id", null: false
    t.string "instruction"
    t.integer "position"
    t.bigint "step_action_id", null: false
    t.datetime "updated_at", null: false
    t.index ["equipment_id"], name: "index_step_action_equipments_on_equipment_id"
    t.index ["step_action_id"], name: "index_step_action_equipments_on_step_action_id"
  end

  create_table "step_action_labels", force: :cascade do |t|
    t.boolean "correct_match"
    t.datetime "created_at", null: false
    t.string "image_url"
    t.string "label_text"
    t.integer "position"
    t.bigint "step_action_id", null: false
    t.datetime "updated_at", null: false
    t.index ["step_action_id"], name: "index_step_action_labels_on_step_action_id"
  end

  create_table "step_action_transfers", force: :cascade do |t|
    t.bigint "chemical_id", null: false
    t.datetime "created_at", null: false
    t.float "quantity"
    t.integer "source_container_id"
    t.bigint "step_action_id", null: false
    t.integer "target_container_id"
    t.datetime "updated_at", null: false
    t.index ["chemical_id"], name: "index_step_action_transfers_on_chemical_id"
    t.index ["step_action_id"], name: "index_step_action_transfers_on_step_action_id"
  end

  create_table "step_actions", force: :cascade do |t|
    t.integer "action_type"
    t.jsonb "config", default: {}, null: false
    t.datetime "created_at", null: false
    t.text "instruction"
    t.bigint "phase_step_id", null: false
    t.integer "position"
    t.datetime "updated_at", null: false
    t.index ["phase_step_id"], name: "index_step_actions_on_phase_step_id"
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

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "assignments", "classrooms"
  add_foreign_key "assignments", "experiments"
  add_foreign_key "assignments", "schools"
  add_foreign_key "assignments", "users", column: "faculty_id"
  add_foreign_key "classroom_memberships", "classrooms"
  add_foreign_key "classroom_memberships", "schools"
  add_foreign_key "classroom_memberships", "users"
  add_foreign_key "classrooms", "schools"
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
  add_foreign_key "phase_steps", "experiment_phases"
  add_foreign_key "step_action_equipments", "equipment"
  add_foreign_key "step_action_equipments", "step_actions"
  add_foreign_key "step_action_labels", "step_actions"
  add_foreign_key "step_action_transfers", "chemicals"
  add_foreign_key "step_action_transfers", "step_actions"
  add_foreign_key "step_actions", "phase_steps"
  add_foreign_key "step_options", "experiment_steps"
  add_foreign_key "submissions", "experiments"
  add_foreign_key "submissions", "schools"
  add_foreign_key "submissions", "users"
  add_foreign_key "users", "departments"
  add_foreign_key "users", "schools"
end
