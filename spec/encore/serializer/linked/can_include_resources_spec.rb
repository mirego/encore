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
  let(:objects) { User.all }

  before do
    run_migrations!
    spawn_objects!
    spawn_serializer!
    create_records!
  end

  context 'without' do
    let(:include) { 'project' }
    let(:spawn_serializer!) do
      spawn_serializer('ProjectSerializer') { attributes :name }
      spawn_serializer('UserSerializer') { attributes :name }
    end

    it { expect(serialized[:linked][:projects]).to eq(nil) }
  end

  context 'with' do
    let(:include) { 'project' }
    let(:spawn_serializer!) do
      spawn_serializer('ProjectSerializer') { attributes :name }
      spawn_serializer('UserSerializer') do
        attributes :name

        def can_include
          %i(project)
        end
      end
    end

    it { expect(serialized[:linked][:projects]).to eq([{ name: project1.name }, { name: project2.name }]) }
  end
end
