require 'spec_helper'

describe Encore::Persister do
  let(:persister) { Encore::Persister::Instance }
  let(:persist!) { persister.new(model, params).persist! }

  let(:run_migrations!) do
    run_migration do
      create_table(:users, force: true) do |t|
        t.string :name, default: nil
        t.string :phone, default: nil
      end
    end
  end

  let(:spawn_models!) do
    spawn_model('User')
  end

  let(:model) { User.create name: 'Bob' }
  let(:params) do
    [{
      id: model.id,
      name: 'Allan',
      phone: '555-2525'
    }]
  end

  before do
    run_migrations!
    spawn_models!
  end

  it { expect { persist! }.to_not change { model.class.count } }
  it { expect { persist! }.to change { model.class.first.name }.to('Allan') }
  it { expect { persist! }.to change { model.class.first.phone }.to('555-2525') }
end
