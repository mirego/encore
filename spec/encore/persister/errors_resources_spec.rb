require 'spec_helper'

describe Encore::Persister do
  let(:persister) { Encore::Persister::Instance.new(model, params) }
  let(:persist!) { persister.persist! }

  let(:run_migrations!) do
    run_migration do
      create_table(:users, force: true) do |t|
        t.string :name, default: nil
      end
    end
  end

  let(:spawn_models!) do
    spawn_model('User') do
      validates :name, presence: true, length: { minimum: 2 }
    end
  end

  before do
    run_migrations!
    spawn_models!
  end

  let(:params) do
    [{
      name: ''
    }]
  end

  let(:expected_errors) do
    [
      {
        path: 'user/0/name',
        title: 'can\'t be blank'
      },
      {
        path: 'user/0/name',
        title: 'is too short (minimum is 2 characters)'
      }
    ]
  end

  context 'create' do
    let(:model) { User }

    it { expect { persist! }.to_not change { model.count } }
    it { expect { persist! }.to change { persister.errors }.to(expected_errors) }
  end

  context 'update' do
    let(:model) { User.create name: 'Robert' }

    it { expect { persist! }.to_not change { model.reload.name } }
    it { expect { persist! }.to change { persister.errors }.to(expected_errors) }
  end
end
