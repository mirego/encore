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

  let(:spawn_objects!) do
    spawn_model('User')
    spawn_serializer('UserSerializer') do
      attributes :snake_case_key

      def snake_case_key
        :name
      end

      def key_mappings
        { snake_case_key: :name }
      end
    end
  end

  let(:model) { User }

  before do
    run_migrations!
    spawn_objects!
  end

  context 'single create' do
    let(:params) do
      [{
        snake_case_key: 'Allan',
        phone: '555-2525'
      }]
    end

    it { expect { persist! }.to change { model.count }.by(1) }
    it { expect { persist! }.to change { model.first.try(:name) }.to('Allan') }
    it { expect { persist! }.to change { model.first.try(:phone) }.to('555-2525') }
  end

  context 'many create' do
    let(:params) do
      [{
        snake_case_key: 'Allan',
        phone: '555-2525'
      }, {
        snake_case_key: 'Bob'
      }]
    end

    it { expect { persist! }.to change { model.count }.by(2) }
    it { expect { persist! }.to change { model.first.try(:name) }.to('Allan') }
    it { expect { persist! }.to change { model.first.try(:phone) }.to('555-2525') }
    it { expect { persist! }.to change { model.last.try(:name) }.to('Bob') }
  end
end
