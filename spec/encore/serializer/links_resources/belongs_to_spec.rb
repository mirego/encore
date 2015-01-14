require 'spec_helper'

describe Encore::Serializer do
  let(:serializer) { Encore::Serializer::Instance }
  let(:objects) { User.all }
  let(:serialized) { serializer.new(objects, include: include).as_json }

  before do
    run_migrations!
    spawn_objects!
    create_records!
  end

  let(:run_migrations!) do
    run_migration do
      create_table(:users, force: true) do |t|
        t.string :name, default: nil
        t.integer :project_id
        t.integer :event_result_id
      end
      create_table(:projects, force: true) do |t|
        t.string :name, default: nil
        t.integer :user_id
      end
      create_table(:event_results, force: true) do |t|
        t.string :score, default: nil
        t.integer :user_id
      end
    end
  end

  let(:spawn_objects!) do
    spawn_model('User') do
      belongs_to :project
    end
    spawn_serializer('UserSerializer') do
      attributes :name, :links

      can_include :project
    end
    spawn_model('Project') do
      has_many :users
    end
    spawn_serializer('ProjectSerializer') do
      attributes :name
    end
  end

  let(:create_records!) do
    User.create name: 'Allan', project_id: 1
    User.create name: 'Doe', project_id: 2
    User.create name: 'Bar', project_id: nil
  end

  context 'not included' do
    let(:include) { '' }
    let(:expected_project) do
      {
        href: '/projects/1',
        id: '1',
        type: 'projects'
      }
    end

    it { expect(serialized[:users][0][:links][:project]).to eq(expected_project) }
  end

  context 'empty association' do
    let(:include) { '' }
    let(:expected_project) do
      nil
    end

    it { expect(serialized[:users][2][:links][:project]).to eq(expected_project) }
  end

  context 'included' do
    let(:include) { 'project' }
    let(:expected_project) { '1' }

    it { expect(serialized[:users][0][:links][:project]).to eq(expected_project) }
  end
end
