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

ActiveRecord::Schema.define(version: 2022_07_13_064337) do

  create_table "inquirements", force: :cascade do |t|
    t.string "name"
    t.integer "state"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "larvata_signing_agents", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "agent_user_id"
    t.datetime "start_at"
    t.datetime "end_at"
    t.text "remark"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["agent_user_id"], name: "index_larvata_signing_agents_on_agent_user_id"
    t.index ["user_id"], name: "index_larvata_signing_agents_on_user_id"
  end

  create_table "larvata_signing_docs", force: :cascade do |t|
    t.integer "larvata_signing_flow_id"
    t.integer "larvata_signing_resource_id"
    t.string "signing_number"
    t.string "title"
    t.text "remark"
    t.integer "remind_period"
    t.integer "state"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "applicant_id"
    t.datetime "committed_at"
    t.integer "applicant_com_id"
    t.integer "applicant_dept_id"
    t.index ["applicant_com_id"], name: "index_larvata_signing_docs_on_applicant_com_id"
    t.index ["applicant_dept_id"], name: "index_larvata_signing_docs_on_applicant_dept_id"
    t.index ["applicant_id"], name: "index_larvata_signing_docs_on_applicant_id"
    t.index ["larvata_signing_flow_id"], name: "index_larvata_signing_docs_on_larvata_signing_flow_id"
    t.index ["larvata_signing_resource_id"], name: "index_larvata_signing_docs_on_larvata_signing_resource_id"
    t.index ["signing_number"], name: "index_larvata_signing_docs_on_signing_number"
    t.index ["state"], name: "index_larvata_signing_docs_on_state"
    t.index ["title"], name: "index_larvata_signing_docs_on_title"
  end

  create_table "larvata_signing_flow_members", force: :cascade do |t|
    t.integer "larvata_signing_flow_stage_id"
    t.bigint "dept_id"
    t.bigint "user_id"
    t.string "role"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "com_id"
    t.index ["com_id"], name: "index_larvata_signing_flow_members_on_com_id"
    t.index ["dept_id"], name: "index_larvata_signing_flow_members_on_dept_id"
    t.index ["larvata_signing_flow_stage_id"], name: "index_larvata_signing_flow_memberds_on_flow_stage_id"
    t.index ["user_id"], name: "index_larvata_signing_flow_members_on_user_id"
  end

  create_table "larvata_signing_flow_stages", force: :cascade do |t|
    t.integer "larvata_signing_flow_id"
    t.integer "typing"
    t.integer "seq"
    t.boolean "supervisor_sign"
    t.text "filter_condition"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["larvata_signing_flow_id"], name: "index_larvata_signing_flow_stages_on_larvata_signing_flow_id"
    t.index ["typing"], name: "index_larvata_signing_flow_stages_on_typing"
  end

  create_table "larvata_signing_flows", force: :cascade do |t|
    t.string "name"
    t.integer "remind_period"
    t.text "remark"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "larvata_signing_records", force: :cascade do |t|
    t.integer "larvata_signing_stage_id"
    t.bigint "signer_id"
    t.bigint "dept_id"
    t.string "role"
    t.integer "signing_result"
    t.text "comment"
    t.bigint "parent_record_id"
    t.integer "state"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "waiting_reason"
    t.bigint "implement_id"
    t.bigint "com_id"
    t.datetime "deadline"
    t.index ["com_id"], name: "index_larvata_signing_records_on_com_id"
    t.index ["dept_id"], name: "index_larvata_signing_records_on_dept_id"
    t.index ["larvata_signing_stage_id"], name: "index_larvata_signing_records_on_larvata_signing_stage_id"
    t.index ["parent_record_id"], name: "index_larvata_signing_records_on_parent_record_id"
    t.index ["signer_id"], name: "index_larvata_signing_records_on_signer_id"
    t.index ["signing_result"], name: "index_larvata_signing_records_on_signing_result"
    t.index ["state"], name: "index_larvata_signing_records_on_state"
  end

  create_table "larvata_signing_resource_records", force: :cascade do |t|
    t.integer "larvata_signing_doc_id"
    t.string "signing_resourceable_type"
    t.bigint "signing_resourceable_id"
    t.integer "state"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["larvata_signing_doc_id", "signing_resourceable_type", "signing_resourceable_id"], name: "index_larvata_signing_resource_records_on_signing_resourceable", unique: true
    t.index ["larvata_signing_doc_id"], name: "index_larvata_signing_resource_records_on_signing_doc_id"
    t.index ["state"], name: "index_larvata_signing_resource_records_on_state"
  end

  create_table "larvata_signing_resources", force: :cascade do |t|
    t.string "code"
    t.string "name"
    t.string "select_model"
    t.string "select_method"
    t.string "view_path"
    t.string "returned_method"
    t.string "approved_method"
    t.string "implement_method"
    t.integer "larvata_signing_flow_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "label_method"
    t.string "submitted_method"
    t.index ["code"], name: "index_larvata_signing_resources_on_code"
    t.index ["larvata_signing_flow_id"], name: "index_larvata_signing_resources_on_larvata_signing_flow_id"
  end

  create_table "larvata_signing_stages", force: :cascade do |t|
    t.integer "larvata_signing_doc_id"
    t.integer "typing"
    t.integer "seq"
    t.integer "state"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "parent_record_id"
    t.index ["larvata_signing_doc_id"], name: "index_larvata_signing_stages_on_larvata_signing_doc_id"
    t.index ["parent_record_id"], name: "index_larvata_signing_stages_on_parent_record_id"
    t.index ["state"], name: "index_larvata_signing_stages_on_state"
    t.index ["typing"], name: "index_larvata_signing_stages_on_typing"
  end

  create_table "larvata_signing_todos", force: :cascade do |t|
    t.bigint "user_id"
    t.integer "typing"
    t.string "title"
    t.text "url"
    t.text "remark"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["typing"], name: "index_larvata_signing_todos_on_typing"
    t.index ["user_id"], name: "index_larvata_signing_todos_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "email"
  end

  add_foreign_key "larvata_signing_docs", "larvata_signing_flows"
  add_foreign_key "larvata_signing_docs", "larvata_signing_resources"
  add_foreign_key "larvata_signing_flow_members", "larvata_signing_flow_stages"
  add_foreign_key "larvata_signing_flow_stages", "larvata_signing_flows"
  add_foreign_key "larvata_signing_records", "larvata_signing_stages"
  add_foreign_key "larvata_signing_resource_records", "larvata_signing_docs"
  add_foreign_key "larvata_signing_resources", "larvata_signing_flows"
end
