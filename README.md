# Virtual Chemistry Lab – Rails Web Application Blueprint

A complete project blueprint for building a web-based virtual chemistry lab using Ruby on Rails 7/8. This document provides structure, database design, routes, and implementation details for developers and educators.
1. Project Overview

Goal: Build a web-based virtual chemistry lab where students can perform experiments safely and visually.
Features:
- 3D virtual lab with chemicals and equipment
- Interactive chemical mixing simulation
- Experiment step guidance
- Reaction observation and result recording
- Faculty dashboard for experiment management



2. Technology Stack

Backend: Ruby on Rails 7/8
Frontend: Hotwire (Turbo + Stimulus) with Three.js integration
Database: PostgreSQL
Authentication: Devise
Authorization: Pundit
3D Graphics: Three.js
Hosting: Render / Heroku / DigitalOcean



3. Database Design

Main Models:
- User: name, email, role (student/faculty)
- Experiment: name, description, instructions
- ExperimentStep: experiment_id, step_number, instruction
- ExperimentResult: user_id, experiment_id, result_data (JSON)
- Chemical: name, formula, color, state
- Equipment: name, type, image_url

Relationships:
- User has_many ExperimentResults
- Experiment has_many ExperimentSteps
- Experiment has_many Chemicals through ExperimentChemicals
- Experiment has_many Equipment through ExperimentEquipments



4. Routes

root "dashboard#index"

Resources :experiments do
member do
get :lab
post :run_step
end
end

resources :experiment_results, only: [:index, :show]



5. Frontend Structure

UI Components:
- Navbar: Dashboard, Experiments, Results, Profile
- Lab Page: 3D simulation area (Three.js)
- Right Panel: Instructions, observations, results

Flow:
1. Student selects experiment
2. Loads 3D scene with equipment and chemicals
3. User interacts via drag/drop or mix buttons
4. Rails backend processes reaction (JSON)
5. Result shown visually and textually



6. Chemical Reaction Logic

Example JSON structure:

{
"HCl + NaOH": {
"products": ["NaCl", "H2O"],
"visual": { "colorChange": "none", "gas": false, "temperature": "heat generated" }
}
}



7. Admin / Faculty Panel

- Create/Edit Experiments
- Manage Chemicals and Equipment
- View Student Results
- Monitor Experiment Usage



8. Authentication & Roles

Devise handles user accounts.
Pundit controls access:
- Student: can perform experiments and view results
- Faculty: can manage experiments and review student activity



9. Suggested File Structure

app/
controllers/
experiments_controller.rb
experiment_results_controller.rb
models/
user.rb
experiment.rb
chemical.rb
equipment.rb
experiment_step.rb
experiment_result.rb
views/
experiments/
index.html.erb
show.html.erb
lab.html.erb
experiment_results/
index.html.erb
show.html.erb
javascript/
controllers/
lab_controller.js
packs/
lab.js



10. Development Roadmap

Month 1: Setup Rails + Devise, build experiment CRUD
Month 2: Implement simulation logic and JSON-based reactions
Month 3: Add Three.js visuals, faculty dashboard, and testing



11. Long-Term Goals

- VR/AR integration using WebXR
- LMS integration for grading
- Advanced chemical simulations (gas release, temperature changes)
- Mobile-friendly interface



This blueprint provides a solid foundation for developing a complete, university-level virtual chemistry lab using Ruby on Rails.
