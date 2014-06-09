require 'spec_helper'

describe Encore::Serializer do
  let(:serializer) { Encore::Serializer::Instance }
  let(:serialized) { serializer.new(objects, page: page, include: include).as_json }

  let(:page) { 1 }

  before do
    run_migrations!
    spawn_objects!
    spawn_serializer!
    create_records!
  end

  let(:run_migrations!) do
    run_migration do
      create_table(:organizations, force: true) do |t|
        t.string :name
      end
      create_table(:users, force: true) do |t|
        t.string :name
        t.integer :project_id
      end
      create_table(:projects, force: true) do |t|
        t.string :name
        t.integer :organization_id
      end
    end
  end

  let(:spawn_serializer!) do
    spawn_serializer('ProjectSerializer') do
      attributes :name

      can_include :organization, :user, :users
    end
    spawn_serializer('UserSerializer') do
      attributes :name

      can_include :project
    end
    spawn_serializer('OrganizationSerializer') do
      attributes :name

      can_include :projects
    end
  end

  let(:include) { 'project' }

  let(:objects) { User.all }
  let(:spawn_objects!) do
    spawn_model('User') { belongs_to :project }
    spawn_model('Project') do
      belongs_to :organization
      has_one :user
    end
    spawn_model('Organization') { has_many :projects }
  end

  let(:org1) { Organization.create name: 'Awesome org' }
  let(:org2) { Organization.create name: 'Medium awesome org' }
  let(:project1) { Project.create name: 'Awesome project', organization: org1 }
  let(:project2) { Project.create name: 'Medium awesome project', organization: org2 }
  let(:user1) { User.create name: 'Alice', project: project1 }
  let(:user2) { User.create name: 'Bob', project: project2 }
  let(:create_records!) do
    user1
    user2
  end

  context 'already included resource' do
    it { expect(serialized[:linked][:projects][0][:links][:user]).to eq(user1.id.to_s) }
    it { expect(serialized[:linked][:projects][1][:links][:user]).to eq(user2.id.to_s) }
  end

  context 'not included resource' do
    it { expect(serialized[:linked][:projects][0][:links][:organization][:id]).to eq(org1.id.to_s) }
    it { expect(serialized[:linked][:projects][1][:links][:organization][:id]).to eq(org2.id.to_s) }
  end
end
