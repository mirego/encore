require 'spec_helper'

describe Encore::Serializer do
  let(:serializer) { Encore::Serializer::Instance }
  let(:serialized) { serializer.new(objects).as_json }

  before do
    run_migrations!
    spawn_models!
    spawn_serializers!
    create_records!
  end

  let(:run_migrations!) do
    run_migration do
      create_table(:users, force: true) do |t|
        t.string :name, default: nil
        t.integer :organization_id
      end
      create_table(:projects, force: true) do |t|
        t.string :name, default: nil
        t.integer :creator_id
        t.integer :user_id
      end
      create_table(:organizations, force: true)
    end
  end

  let(:spawn_models!) do
    spawn_model('Organization') do
      has_many :artists, class_name: 'User'
    end
    spawn_model('User') do
      has_one :awesome_project, class_name: 'Project'
    end
    spawn_model('Project') do
      belongs_to :creator, class_name: 'User'
    end
  end

  let(:create_records!) do
    Organization.create
    p1 = Project.create name: 'p1', creator_id: 1
    p2 = Project.create name: 'p2', creator_id: 2
    User.create name: 'Allan', awesome_project: p1, organization_id: 1
    User.create name: 'Doe', awesome_project: p2, organization_id: 1
  end

  context 'default root key' do
    let(:spawn_serializers!) do
      spawn_serializer('OrganizationSerializer') do
        can_include :artists
      end
      spawn_serializer('UserSerializer') do
        can_include :awesome_project
      end
      spawn_serializer('ProjectSerializer') do
        can_include :creator
      end
    end
    context 'has_one' do
      let(:objects) { User.all }
      let(:expected_project) do
        {
          href: '/users/1/project',
          type: 'projects'
        }
      end

      it { expect(serialized[:users][0][:links][:awesome_project]).to eq(expected_project) }
    end

    context 'has_many' do
      let(:objects) { Organization.all }
      let(:expected_artists) do
        {
          href: '/users?organization_id=1',
          type: 'users'
        }
      end

      it { expect(serialized[:organizations][0][:links][:artists]).to eq(expected_artists) }
    end

    context 'belongs_to' do
      let(:objects) { Project.all }
      let(:expected_creator) do
        {
          href: '/users/1',
          id: '1',
          type: 'users'
        }
      end

      it { expect(serialized[:projects][0][:links][:creator]).to eq(expected_creator) }
    end
  end

  context 'custom root key' do
    let(:spawn_serializers!) do
      spawn_serializer('OrganizationSerializer') do
        can_include :artists
        root_key :super_organizations
      end
      spawn_serializer('UserSerializer') do
        can_include :awesome_project
        root_key :creators
      end
      spawn_serializer('ProjectSerializer') do
        can_include :creator
        root_key :awesome_projects
      end
    end
    context 'has_one' do
      let(:objects) { User.all }
      let(:expected_project) do
        {
          href: '/creators/1/awesome_project',
          type: 'awesome_projects'
        }
      end

      it { expect(serialized[:creators][0][:links][:awesome_project]).to eq(expected_project) }
    end

    context 'has_many' do
      let(:objects) { Organization.all }
      let(:expected_artists) do
        {
          href: '/creators?organization_id=1',
          type: 'creators'
        }
      end

      it { expect(serialized[:super_organizations][0][:links][:artists]).to eq(expected_artists) }
    end

    context 'belongs_to' do
      let(:objects) { Project.all }
      let(:expected_creator) do
        {
          href: '/creators/1',
          id: '1',
          type: 'creators'
        }
      end

      it { expect(serialized[:awesome_projects][0][:links][:creator]).to eq(expected_creator) }
    end
  end
end
