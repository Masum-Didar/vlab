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

ActiveRecord::Schema[8.1].define(version: 2025_11_21_111810) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "chemicals", force: :cascade do |t|
    t.string "color_hex"
    t.datetime "created_at", null: false
    t.string "formula"
    t.string "name"
    t.jsonb "properties"
    t.string "state"
    t.datetime "updated_at", null: false
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

  create_table "experiment_results", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.jsonb "data"
    t.bigint "experiment_id", null: false
    t.integer "status"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["experiment_id"], name: "index_experiment_results_on_experiment_id"
    t.index ["user_id"], name: "index_experiment_results_on_user_id"
  end

  create_table "experiment_steps", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.jsonb "expected_action"
    t.bigint "experiment_id", null: false
    t.text "instruction"
    t.integer "step_number"
    t.datetime "updated_at", null: false
    t.index ["experiment_id"], name: "index_experiment_steps_on_experiment_id"
  end

  create_table "experiments", force: :cascade do |t|
    t.jsonb "config"
    t.datetime "created_at", null: false
    t.text "description"
    t.integer "difficulty"
    t.boolean "published"
    t.string "title"
    t.datetime "updated_at", null: false
  end

  create_table "lab_sessions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "ended_at"
    t.bigint "experiment_id", null: false
    t.datetime "started_at"
    t.integer "status"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["experiment_id"], name: "index_lab_sessions_on_experiment_id"
    t.index ["user_id"], name: "index_lab_sessions_on_user_id"
  end

  create_table "submissions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.jsonb "data"
    t.bigint "experiment_id", null: false
    t.integer "status"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["experiment_id"], name: "index_submissions_on_experiment_id"
    t.index ["user_id"], name: "index_submissions_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "first_name"
    t.string "last_name"
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.integer "role", default: 0
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "experiment_chemicals", "chemicals"
  add_foreign_key "experiment_chemicals", "experiments"
  add_foreign_key "experiment_equipments", "equipment"
  add_foreign_key "experiment_equipments", "experiments"
  add_foreign_key "experiment_results", "experiments"
  add_foreign_key "experiment_results", "users"
  add_foreign_key "experiment_steps", "experiments"
  add_foreign_key "lab_sessions", "experiments"
  add_foreign_key "lab_sessions", "users"
  add_foreign_key "submissions", "experiments"
  add_foreign_key "submissions", "users"
end
