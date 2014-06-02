require 'spec_helper'

describe Encore::Serializer do
  let(:serializer) { Encore::Serializer::Instance }
  let(:objects) { User.all }
  let(:serialized) { serializer.new(objects).as_json }

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
    User.create name: 'Allan', discarded_attribute: 'THIS IS MY PASSWORD'
    User.create name: 'Doe'
  end

  before do
    run_migrations!
    spawn_objects!
    create_records!
  end

  it { expect(serialized[:users].count).to eq(2) }
  it { expect(serialized[:users]).to eq([{ name: 'Allan', links: {} }, { name: 'Doe', links: {} }]) }
end
