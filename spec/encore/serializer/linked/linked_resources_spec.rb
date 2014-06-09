require 'spec_helper'

describe Encore::Serializer do
  let(:serializer) { Encore::Serializer::Instance }
  let(:serialized) { serializer.new(objects, page: page, include: include).as_json }

  let(:run_migrations!) do
    run_migration do
      create_table(:users, force: true) do |t|
        t.string :name, default: nil
        t.string :discarded_attribute, default: nil
        t.integer :project_id
      end

      create_table(:projects, force: true) do |t|
        t.string :name, default: nil
        t.string :discarded_attribute, default: nil
      end
    end
  end

  let(:project1) { Project.create name: 'Awesome project' }
  let(:project2) { Project.create name: 'Medium awesome project' }
  let(:page) { 1 }
  let(:spawn_serializer!) do
    spawn_serializer('ProjectSerializer') do
      attributes :name

      can_include :user, :users
    end
    spawn_serializer('UserSerializer') do
      attributes :name

      can_include :project
    end
  end

  before do
    run_migrations!
    spawn_objects!
    spawn_serializer!
    create_records!
  end

  context 'belongs_to include' do
    let(:objects) { User.all }
    let(:spawn_objects!) do
      spawn_model('User') { belongs_to :project }
      spawn_model('Project')
    end

    let(:create_records!) do
      User.create name: 'Allan', project_id: project1.id
      User.create name: 'Doe', project_id: project2.id
      User.create name: 'Ding', project_id: project1.id
      User.create name: 'Bob', project_id: project2.id
    end

    let(:include) { 'project' }

    it { expect(serialized[:linked][:projects]).to eq([{ name: project1.name, links: {} }, { name: project2.name, links: {} }]) }
  end

  context 'has_many include' do
    let(:objects) { Project.all }
    let(:spawn_objects!) do
      spawn_model('User')
      spawn_model('Project') { has_many :users }
    end

    let(:create_records!) do
      User.create name: 'Allan', project_id: project1.id
      User.create name: 'Doe', project_id: project2.id
      User.create name: 'Ding', project_id: project1.id
      User.create name: 'Bob', project_id: project2.id
    end

    let(:include) { 'users' }

    it { expect(serialized[:linked][:users]).to eq([{ name: 'Allan', links: {} }, { name: 'Doe', links: {} }, { name: 'Ding', links: {} }, { name: 'Bob', links: {} }]) }
  end

  context 'has_one include' do
    let(:objects) { Project.all }
    let(:spawn_objects!) do
      spawn_model('User')
      spawn_model('Project') { has_one :user }
    end

    let(:create_records!) do
      User.create name: 'Allan', project_id: project1.id
      User.create name: 'Doe', project_id: project2.id
    end

    let(:include) { 'user' }

    it { expect(serialized[:linked][:users]).to eq([{ name: 'Allan', links: {} }, { name: 'Doe', links: {} }]) }
  end
end
