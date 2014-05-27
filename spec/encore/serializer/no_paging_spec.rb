require 'spec_helper'

describe Encore::Serializer do
  let(:serializer) { Encore::Serializer::Instance }
  let(:objects) { User.all }
  let(:serialized) { serializer.new(objects, skip_paging: true).as_json }

  let(:run_migrations!) do
    run_migration do
      create_table(:users, force: true) do |t|
        t.string :name, default: nil
        t.string :discarded_attribute, default: nil
      end
    end
  end

  let(:spawn_objects!) do
    spawn_model('User')
    spawn_serializer('UserSerializer') do
      attributes :name
    end
  end

  let(:create_records!) do
    User.create name: 'Allan'
    User.create name: 'Doe'
    User.create name: 'Ding'
    User.create name: 'Bob'
  end

  before do
    expect(User).to receive(:page).never
    run_migrations!
    spawn_objects!
    create_records!
  end

  it { expect(serialized[:meta]).to eq({}) }
  it { expect(serialized[:users].count).to eq(4) }
end
