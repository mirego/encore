require 'spec_helper'

describe Encore::Persister do
  let(:persister) { Encore::Persister::Instance }
  let(:persist!) { persister.new(model, params).persist! }

  before do
    run_migrations!
    spawn_models!
  end

  let(:run_migrations!) do
    run_migration do
      create_table(:users, force: true) do |t|
        t.string :name, default: nil
        t.integer :project_id, default: nil
      end
      create_table(:projects, force: true) do |t|
        t.string :name, default: nil
      end
    end
  end

  let(:spawn_models!) do
    spawn_model('User') do
      belongs_to :project
    end
    spawn_model('Project')
  end

  let(:model) { User }
  let(:project1) { Project.create name: 'a' }

  let(:params) do
    [{
      name: 'Allan',
      links: {
        project: project1.id.to_s
      }
    }]
  end

  it { expect { persist! }.to change { model.count }.by(1) }
  it { expect { persist! }.to change { model.first.try(:name) }.to('Allan') }
  it { expect { persist! }.to change { model.first.try(:project) }.to(project1) }
end
