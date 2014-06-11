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

  context 'underscore route name' do
    let(:spawn_objects!) do
      spawn_model('User') do
        has_many :event_results
      end
      spawn_serializer('UserSerializer') do
        attributes :name, :links

        def can_include
          %i(event_results)
        end
      end
      spawn_model('EventResult') do
        belongs_to :user
      end
      spawn_serializer('EventResultSerializer') do
        attributes :score
      end
    end

    let(:create_records!) do
      User.create name: 'Allan'
      User.create name: 'Doe'
      EventResult.create score: 'p1', user_id: 1
      EventResult.create score: 'p2', user_id: 1
    end

    let(:include) { '' }
    let(:expected_event_results) do
      {
        href: '/event_results?user_id=1',
        type: 'event_results'
      }
    end

    it { expect(serialized[:users][0][:links][:event_results]).to eq(expected_event_results) }
  end

  context 'underscore id' do
    let(:spawn_objects!) do
      spawn_model('User')
      spawn_serializer('UserSerializer') do
        attributes :name, :links
      end
      spawn_model('EventResult') do
        has_many :users
      end
      spawn_serializer('EventResultSerializer') do
        attributes :score

        def can_include
          %i(users)
        end
      end
    end

    let(:create_records!) do
      EventResult.create score: 'p1'
      EventResult.create score: 'p2'
      User.create name: 'Allan', event_result_id: 1
      User.create name: 'Doe', event_result_id: 1
    end

    let(:objects) { EventResult.all }
    let(:include) { '' }
    let(:expected_users) do
      {
        href: '/users?event_result_id=1',
        type: 'users'
      }
    end

    it { expect(serialized[:event_results][0][:links][:users]).to eq(expected_users) }
  end
end
