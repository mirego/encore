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
      end
      create_table(:groups, force: true) do |t|
        t.string :name, default: nil
        t.integer :user_id, default: nil
      end
    end
  end

  let(:spawn_models!) do
    spawn_model('User') do
      has_many :groups
    end
    spawn_model('Group') do
      belongs_to :user
    end
  end

  let(:model) { User }
  let(:group1) { Group.create name: 'a' }
  let(:group2) { Group.create name: 'b' }

  let(:params) do
    [{
      name: 'Allan',
      links: {
        groups: [group1.id.to_s, group2.id.to_s]
      }
    }]
  end

  it { expect { persist! }.to change { model.count }.by(1) }
  it { expect { persist! }.to change { model.first.try(:name) }.to('Allan') }
  it { expect { persist! }.to change { model.first.try(:groups).try(:count) }.to(2) }
end
