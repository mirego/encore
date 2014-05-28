require 'spec_helper'

describe Encore::Serializer do
  let(:serializer) { Encore::Serializer::Instance }
  let(:objects) { User.all }
  let(:serialized) { serializer.new(objects, page: page).as_json }

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

  let(:paging_config) do
    double(
      'Kaminari',
      page_method_name: 'page',
      default_per_page: 1,
      max_per_page: 1,
      max_pages: 10
    )
  end

  before do
    expect(Kaminari).to receive(:config).and_return(paging_config).at_least(:once)
    run_migrations!
    spawn_objects!
    create_records!
  end

  context 'page 1' do
    let(:page) { 1 }

    it { expect(serialized[:meta][:users][:page]).to eq(1) }
    it { expect(serialized[:meta][:users][:count]).to eq(4) }
    it { expect(serialized[:meta][:users][:page_count]).to eq(4) }
    it { expect(serialized[:meta][:users][:next_page]).to eq(2) }
  end

  context 'page 2' do
    let(:page) { 2 }

    it { expect(serialized[:meta][:users][:page]).to eq(2) }
    it { expect(serialized[:meta][:users][:count]).to eq(4) }
    it { expect(serialized[:meta][:users][:page_count]).to eq(4) }
    it { expect(serialized[:meta][:users][:previous_page]).to eq(1) }
    it { expect(serialized[:meta][:users][:next_page]).to eq(3) }
  end
end
