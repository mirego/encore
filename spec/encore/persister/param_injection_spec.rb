require 'spec_helper'

describe Encore::Persister do
  let(:persister) { Encore::Persister::Instance }
  let(:persist!) { persister.new(model, params, options).persist! }

  let(:run_migrations!) do
    run_migration do
      create_table(:users, force: true) do |t|
        t.string :name, default: nil
        t.integer :creator_id
      end
    end
  end

  let(:spawn_objects!) do
    spawn_model('User')
    spawn_serializer('UserSerializer')
  end

  let(:model) { User }

  before do
    run_migrations!
    spawn_objects!
  end

  context 'single inject' do
    let(:options) do
      {
        inject_params: {
          creator_id: '1'
        }
      }
    end
    let(:params) do
      [{
        name: 'Allan'
      }]
    end

    it { expect { persist! }.to change { model.count }.by(1) }
    it { expect { persist! }.to change { model.first.try(:name) }.to('Allan') }
    it { expect { persist! }.to change { model.first.try(:creator_id) }.to(1) }
  end
end
