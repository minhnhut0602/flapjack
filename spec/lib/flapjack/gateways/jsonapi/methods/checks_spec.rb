require 'spec_helper'
require 'flapjack/gateways/jsonapi'

describe 'Flapjack::Gateways::JSONAPI::Methods::Checks', :sinatra => true, :logger => true, :pact_fixture => true do

  include_context "jsonapi"

  let(:check)   { double(Flapjack::Data::Check, :id => check_data[:id]) }
  let(:check_2) { double(Flapjack::Data::Check, :id => check_2_data[:id]) }
  let(:tag)     { double(Flapjack::Data::Tag, :id => tag_data[:name]) }

  def check_json(ch_data)
    id = ch_data[:id]
    {
      :id => id,
      :type => 'check',
      :attributes => ch_data.reject {|k,v| :id.eql?(k) },
      :relationships => {
        :alerting_media => {
          :links => {
            :self => "http://example.org/checks/#{id}/relationships/alerting_media",
            :related => "http://example.org/checks/#{id}/alerting_media"
          }
        },
        :contacts => {
          :links => {
            :self => "http://example.org/checks/#{id}/relationships/contacts",
            :related => "http://example.org/checks/#{id}/contacts"
          }
         },
        :current_scheduled_maintenances =>  {
          :links => {
            :self => "http://example.org/checks/#{id}/relationships/current_scheduled_maintenances",
            :related => "http://example.org/checks/#{id}/current_scheduled_maintenances"
          }
        },
        :current_state => {
          :links => {
            :self => "http://example.org/checks/#{id}/relationships/current_state",
            :related => "http://example.org/checks/#{id}/current_state"
          }
        },
        :current_unscheduled_maintenance => {
          :links => {
            :self => "http://example.org/checks/#{id}/relationships/current_unscheduled_maintenance",
            :related => "http://example.org/checks/#{id}/current_unscheduled_maintenance"
          }
        },
        :latest_notifications => {
          :links => {
            :self => "http://example.org/checks/#{id}/relationships/latest_notifications",
            :related => "http://example.org/checks/#{id}/latest_notifications"
          }
        },
        :scheduled_maintenances => {
          :links => {
            :self => "http://example.org/checks/#{id}/relationships/scheduled_maintenances",
            :related => "http://example.org/checks/#{id}/scheduled_maintenances"
          }
        },
        :states => {
          :links => {
            :self => "http://example.org/checks/#{id}/relationships/states",
            :related => "http://example.org/checks/#{id}/states"
          }
        },
        :tags => {
          :links => {
            :self => "http://example.org/checks/#{id}/relationships/tags",
            :related => "http://example.org/checks/#{id}/tags"
          }
        },
        :unscheduled_maintenances => {
          :links => {
            :self => "http://example.org/checks/#{id}/relationships/unscheduled_maintenances",
            :related => "http://example.org/checks/#{id}/unscheduled_maintenances"
          }
        }
      }
    }
  end

  it "creates a check" do
    expect(Flapjack::Data::Check).to receive(:lock).
      with(Flapjack::Data::ScheduledMaintenance, Flapjack::Data::Tag,
           Flapjack::Data::Contact, Flapjack::Data::Rule,
           Flapjack::Data::Route, Flapjack::Data::UnscheduledMaintenance).
      and_yield

    empty_ids = double('empty_ids')
    expect(empty_ids).to receive(:ids).and_return([])
    expect(Flapjack::Data::Check).to receive(:intersect).
      with(:id => [check_data[:id]]).and_return(empty_ids)

    expect(check).to receive(:invalid?).and_return(false)
    expect(check).to receive(:save!).and_return(true)
    expect(Flapjack::Data::Check).to receive(:new).with(check_data).
      and_return(check)

    expect(check).to receive(:as_json).with(:only => an_instance_of(Array)).
      and_return(check_data)

    expect(Flapjack::Data::Check).to receive(:jsonapi_type).and_return('check')

    post "/checks", Flapjack.dump_json(:data => check_data.merge(:type => 'check')), jsonapi_env
    expect(last_response.status).to eq(201)

    expect(last_response.body).to be_json_eql(Flapjack.dump_json(:data =>
      check_json(check_data)))
  end

  it 'creates two checks' do
    expect(Flapjack::Data::Check).to receive(:lock).
      with(Flapjack::Data::ScheduledMaintenance, Flapjack::Data::Tag,
           Flapjack::Data::Contact, Flapjack::Data::Rule,
           Flapjack::Data::Route, Flapjack::Data::UnscheduledMaintenance).
      and_yield

    empty_ids = double('empty_ids')
    expect(empty_ids).to receive(:ids).and_return([])
    expect(Flapjack::Data::Check).to receive(:intersect).
      with(:id => [check_data[:id], check_2_data[:id]]).and_return(empty_ids)

    expect(check).to receive(:invalid?).and_return(false)
    expect(check).to receive(:save!).and_return(true)
    expect(Flapjack::Data::Check).to receive(:new).with(check_data).
      and_return(check)

    expect(check_2).to receive(:invalid?).and_return(false)
    expect(check_2).to receive(:save!).and_return(true)
    expect(Flapjack::Data::Check).to receive(:new).with(check_2_data).
      and_return(check_2)

    expect(check).to receive(:as_json).with(:only => an_instance_of(Array)).
      and_return(check_data)

    expect(check_2).to receive(:as_json).with(:only => an_instance_of(Array)).
      and_return(check_2_data)

    expect(Flapjack::Data::Check).to receive(:jsonapi_type).and_return('check')

    post "/checks", Flapjack.dump_json(:data => [check_data.merge(:type => 'check'),
                                                 check_2_data.merge(:type => 'check')]), jsonapi_bulk_env
    expect(last_response.status).to eq(201)

    expect(last_response.body).to be_json_eql(Flapjack.dump_json(:data => [
      check_json(check_data), check_json(check_2_data)]))
  end

  it 'creates a link to a tag along with a check' do
    expect(Flapjack::Data::Check).to receive(:lock).
      with(Flapjack::Data::ScheduledMaintenance, Flapjack::Data::Tag,
           Flapjack::Data::Contact, Flapjack::Data::Rule,
           Flapjack::Data::Route, Flapjack::Data::UnscheduledMaintenance).
      and_yield

    empty_ids = double('empty_ids')
    expect(empty_ids).to receive(:ids).and_return([])
    expect(Flapjack::Data::Check).to receive(:intersect).
      with(:id => [check_data[:id]]).and_return(empty_ids)

    expect(check).to receive(:invalid?).and_return(false)
    expect(check).to receive(:save!).and_return(true)
    expect(Flapjack::Data::Check).to receive(:new).with(check_data).
      and_return(check)

    expect(Flapjack::Data::Tag).to receive(:find_by_ids!).
      with(tag.id).and_return([tag])

    tags = double('tags')
    expect(tags).to receive(:add).with(tag)
    expect(check).to receive(:tags).and_return(tags)

    expect(check).to receive(:as_json).with(:only => an_instance_of(Array)).
      and_return(check_data)

    expect(Flapjack::Data::Check).to receive(:jsonapi_type).and_return('check')

    post "/checks", Flapjack.dump_json(:data => check_data.merge(:type => 'check', :links => {
      :tags => {:linkage => [:id => tag.id, :type => 'tag']}
    })), jsonapi_env
    expect(last_response.status).to eq(201)
    expect(last_response.body).to be_json_eql(Flapjack.dump_json(:data =>
      check_json(check_data)))
  end

  it 'rejects a request to create a check with an invalid bulk MIME type' do
    post "/checks", Flapjack.dump_json(:data => check_data.merge(:type => 'check')), jsonapi_bulk_env
    expect(last_response.status).to eq(406)
    expect(last_response.body).to be_json_eql(Flapjack.dump_json(
      :errors => [{:detail => 'JSONAPI Bulk Extension was set in headers', :status => "406"}]
    ))
  end

  it 'rejects a request to create two checks with an invalid bulk MIME type' do
    post "/checks", Flapjack.dump_json(:data => [check_data.merge(:type => 'check'),
                                                 check_2_data.merge(:type => 'check')]), jsonapi_env
    expect(last_response.status).to eq(406)
    expect(last_response.body).to be_json_eql(Flapjack.dump_json(
      :errors => [{:detail => 'JSONAPI Bulk Extension not set in headers', :status => "406"}]
    ))
  end

  it "retrieves paginated checks" do
    expect(Flapjack::Data::Check).to receive(:lock).
      with(Flapjack::Data::Medium, Flapjack::Data::Contact,
           Flapjack::Data::ScheduledMaintenance, Flapjack::Data::State,
           Flapjack::Data::UnscheduledMaintenance, Flapjack::Data::Tag,
           Flapjack::Data::Rule, Flapjack::Data::Route).
      and_yield

    meta = {
      :pagination => {
        :page        => 1,
        :per_page    => 20,
        :total_pages => 1,
        :total_count => 1
      }
    }

    links = {
      :self  => 'http://example.org/checks',
      :first => 'http://example.org/checks?page=1',
      :last  => 'http://example.org/checks?page=1'
    }

    page = double('page')
    expect(page).to receive(:empty?).and_return(false)
    expect(page).to receive(:ids).and_return([check.id])
    expect(page).to receive(:collect) {|&arg| [arg.call(check)] }
    sorted = double('sorted')
    expect(sorted).to receive(:page).with(1, :per_page => 20).
      and_return(page)
    expect(sorted).to receive(:count).and_return(1)
    expect(Flapjack::Data::Check).to receive(:sort).
      with(:id).and_return(sorted)

    expect(check).to receive(:as_json).with(:only => an_instance_of(Array)).
      and_return(check_data)

    expect(Flapjack::Data::Check).to receive(:jsonapi_type).and_return('check')

    get '/checks'
    expect(last_response).to be_ok
    expect(last_response.body).to be_json_eql(Flapjack.dump_json(:data =>
      [check_json(check_data)], :links => links, :meta => meta))
  end

  it "retrieves paginated checks matching a filter" do
    expect(Flapjack::Data::Check).to receive(:lock).
      with(Flapjack::Data::Medium, Flapjack::Data::Contact,
           Flapjack::Data::ScheduledMaintenance, Flapjack::Data::State,
           Flapjack::Data::UnscheduledMaintenance, Flapjack::Data::Tag,
           Flapjack::Data::Rule, Flapjack::Data::Route).
      and_yield

    meta = {
      :pagination => {
        :page        => 1,
        :per_page    => 20,
        :total_pages => 1,
        :total_count => 1
      }
    }

    links = {
      :self  => 'http://example.org/checks?filter%5B%5D=enabled%3At',
      :first => 'http://example.org/checks?filter%5B%5D=enabled%3At&page=1',
      :last  => 'http://example.org/checks?filter%5B%5D=enabled%3At&page=1'
    }

    filtered = double('filtered')
    expect(Flapjack::Data::Check).to receive(:intersect).with(:enabled => true).
      and_return(filtered)

    page = double('page')
    expect(page).to receive(:empty?).and_return(false)
    expect(page).to receive(:ids).and_return([check.id])
    expect(page).to receive(:collect) {|&arg| [arg.call(check)] }
    sorted = double('sorted')
    expect(sorted).to receive(:page).with(1, :per_page => 20).and_return(page)
    expect(sorted).to receive(:count).and_return(1)
    expect(filtered).to receive(:sort).with(:id).and_return(sorted)

    expect(check).to receive(:as_json).with(:only => an_instance_of(Array)).
      and_return(check_data)

    expect(Flapjack::Data::Check).to receive(:jsonapi_type).and_return('check')

    get '/checks?filter=enabled%3At'
    expect(last_response).to be_ok
    expect(last_response.body).to be_json_eql(Flapjack.dump_json(:data =>
      [check_json(check_data)], :links => links, :meta => meta))
  end

  it "retrieves one check" do
    expect(Flapjack::Data::Check).to receive(:lock).
      with(Flapjack::Data::Medium, Flapjack::Data::Contact,
           Flapjack::Data::ScheduledMaintenance, Flapjack::Data::State,
           Flapjack::Data::UnscheduledMaintenance, Flapjack::Data::Tag,
           Flapjack::Data::Rule, Flapjack::Data::Route).
      and_yield

    expect(Flapjack::Data::Check).to receive(:intersect).
      with(:id => check.id).and_return([check])

    expect(check).to receive(:as_json).with(:only => an_instance_of(Array)).
      and_return(check_data)

    expect(Flapjack::Data::Check).to receive(:jsonapi_type).and_return('check')

    get "/checks/#{check.id}"
    expect(last_response).to be_ok
    expect(last_response.body).to be_json_eql(Flapjack.dump_json(
      :data => check_json(check_data),
      :links => {:self => "http://example.org/checks/#{check.id}"}))
  end

  it "retrieves one check with a subset of fields" do
    expect(Flapjack::Data::Check).to receive(:lock).
      with(Flapjack::Data::Medium, Flapjack::Data::Contact,
           Flapjack::Data::ScheduledMaintenance, Flapjack::Data::State,
           Flapjack::Data::UnscheduledMaintenance, Flapjack::Data::Tag,
           Flapjack::Data::Rule, Flapjack::Data::Route).
      and_yield

    expect(Flapjack::Data::Check).to receive(:intersect).
      with(:id => check.id).and_return([check])

    expect(check).to receive(:as_json).with(:only => [:name, :enabled]).
      and_return(check_data)

    expect(Flapjack::Data::Check).to receive(:jsonapi_type).and_return('check')

    get "/checks/#{check.id}?fields=name%2Cenabled"
    expect(last_response).to be_ok

    expect(last_response.body).to be_json_eql(Flapjack.dump_json(
      :data => check_json(check_data),
      :links => {:self => "http://example.org/checks/#{check.id}?fields=name%2Cenabled"}))
  end

  it "retrieves one check and all its linked tag records" do
    expect(Flapjack::Data::Check).to receive(:lock).
      with(Flapjack::Data::Medium, Flapjack::Data::Contact,
           Flapjack::Data::ScheduledMaintenance, Flapjack::Data::State,
           Flapjack::Data::UnscheduledMaintenance, Flapjack::Data::Tag,
           Flapjack::Data::Rule, Flapjack::Data::Route).
      and_yield

    checks = double('checks')
    expect(checks).to receive(:empty?).and_return(false)
    expect(checks).to receive(:collect) {|&arg| [arg.call(check)] }
    expect(checks).to receive(:associated_ids_for).with(:tags).
      and_return(check.id => [tag.id])
    expect(Flapjack::Data::Check).to receive(:intersect).
      with(:id => check.id).and_return(checks)

    full_tags = double('full_tags')
    expect(full_tags).to receive(:collect) {|&arg| [arg.call(tag)] }

    expect(Flapjack::Data::Tag).to receive(:intersect).
      with(:id => [tag.id]).and_return(full_tags)

    expect(tag).to receive(:as_json).with(:only => an_instance_of(Array)).
      and_return(tag_data.merge(:id => tag.id))

    expect(check).to receive(:as_json).with(:only => an_instance_of(Array)).
      and_return(check_data)

    expect(Flapjack::Data::Check).to receive(:jsonapi_type).and_return('check')
    expect(Flapjack::Data::Tag).to receive(:jsonapi_type).twice.and_return('tag')

    get "/checks/#{check.id}?include=tags"
    expect(last_response).to be_ok

    response_data = check_json(check_data)
    response_data[:relationships][:tags][:data] = [{:type => 'tag', :id => tag.id}]

    expect(last_response.body).to be_json_eql(Flapjack.dump_json(
      :data => response_data,
      :included => [{
        :id => tag.id,
        :type => 'tag',
        :attributes => tag_data,
        :relationships => {
          :checks => {
            :links => {
              :self => "http://example.org/tags/#{tag.id}/relationships/checks",
              :related => "http://example.org/tags/#{tag.id}/checks"
            }
          },
          :rules => {
            :links => {
              :self => "http://example.org/tags/#{tag.id}/relationships/rules",
              :related => "http://example.org/tags/#{tag.id}/rules"
            }
          }
        }
        # :links => {
        #   :self  => "http://example.org/tags/#{tag.id}"
        # }
      }],
      :links => {:self => "http://example.org/checks/#{check.id}?include=tags"}))
  end

  it 'retrieves two checks' do
    expect(Flapjack::Data::Check).to receive(:lock).
      with(Flapjack::Data::Medium, Flapjack::Data::Contact,
           Flapjack::Data::ScheduledMaintenance, Flapjack::Data::State,
           Flapjack::Data::UnscheduledMaintenance, Flapjack::Data::Tag,
           Flapjack::Data::Rule, Flapjack::Data::Route).
      and_yield

    meta = {
      :pagination => {
        :page        => 1,
        :per_page    => 20,
        :total_pages => 1,
        :total_count => 2
      }
    }

    links = {
      :self  => "http://example.org/checks?filter%5B%5D=id%3A#{check.id}%7C#{check_2.id}",
      :first => "http://example.org/checks?filter%5B%5D=id%3A#{check.id}%7C#{check_2.id}&page=1",
      :last  => "http://example.org/checks?filter%5B%5D=id%3A#{check.id}%7C#{check_2.id}&page=1"
    }

    check_2 = double(Flapjack::Data::Check, :id => check_2_data[:id])

    page = double('page', :all => [check, check_2])
    page = double('page')
    expect(page).to receive(:empty?).and_return(false)
    expect(page).to receive(:ids).and_return([check.id])
    expect(page).to receive(:collect) {|&arg| [arg.call(check), arg.call(check_2)] }

    sorted = double('sorted')
    expect(sorted).to receive(:page).with(1, :per_page => 20).and_return(page)
    expect(sorted).to receive(:count).and_return(2)

    filtered = double('filtered')
    expect(filtered).to receive(:sort).with(:id).and_return(sorted)
    expect(Flapjack::Data::Check).to receive(:intersect).with(:id => [check.id, check_2.id]).
      and_return(filtered)

    expect(check).to receive(:as_json).with(:only => an_instance_of(Array)).
      and_return(check_data)

    expect(check_2).to receive(:as_json).with(:only => an_instance_of(Array)).
      and_return(check_2_data)

    expect(Flapjack::Data::Check).to receive(:jsonapi_type).and_return('check')

    get "/checks?filter=id%3A#{check.id}%7C#{check_2.id}"
    expect(last_response).to be_ok
    expect(last_response.body).to be_json_eql(Flapjack.dump_json(:data =>
      [check_json(check_data), check_json(check_2_data)], :links => links, :meta => meta))
  end

  it 'disables a check' do
    expect(Flapjack::Data::Check).to receive(:lock).
      with(Flapjack::Data::ScheduledMaintenance, Flapjack::Data::Tag,
           Flapjack::Data::Contact, Flapjack::Data::Rule,
           Flapjack::Data::Route, Flapjack::Data::UnscheduledMaintenance).
      and_yield

    expect(Flapjack::Data::Check).to receive(:find_by_id!).
      with(check.id).and_return(check)

    expect(check).to receive(:enabled=).with(false)
    expect(check).to receive(:invalid?).and_return(false)
    expect(check).to receive(:save!).and_return(true)

    expect(Flapjack::Data::Check).to receive(:jsonapi_type).and_return('check')

    patch "/checks/#{check.id}",
      Flapjack.dump_json(:data => {:id => check.id, :type => 'check', :enabled => false}),
      jsonapi_env
    expect(last_response.status).to eq(204)
  end

  it 'disables two checks' do
    expect(Flapjack::Data::Check).to receive(:lock).
      with(Flapjack::Data::ScheduledMaintenance, Flapjack::Data::Tag,
           Flapjack::Data::Contact, Flapjack::Data::Rule,
           Flapjack::Data::Route, Flapjack::Data::UnscheduledMaintenance).
      and_yield

    expect(Flapjack::Data::Check).to receive(:find_by_ids!).
      with(check.id, check_2.id).and_return([check, check_2])

    expect(check).to receive(:enabled=).with(false)
    expect(check).to receive(:invalid?).and_return(false)
    expect(check).to receive(:save!).and_return(true)

    expect(check_2).to receive(:enabled=).with(false)
    expect(check_2).to receive(:invalid?).and_return(false)
    expect(check_2).to receive(:save!).and_return(true)

    expect(Flapjack::Data::Check).to receive(:jsonapi_type).and_return('check')

    patch "/checks",
      Flapjack.dump_json(:data => [{:id => check.id, :type => 'check', :enabled => false},
                                   {:id => check_2.id, :type => 'check', :enabled => false}]),
      jsonapi_bulk_env
    expect(last_response.status).to eq(204)
  end

  it "replaces the tags for a check" do
    expect(Flapjack::Data::Check).to receive(:lock).
      with(Flapjack::Data::ScheduledMaintenance, Flapjack::Data::Tag,
           Flapjack::Data::Contact, Flapjack::Data::Rule,
           Flapjack::Data::Route, Flapjack::Data::UnscheduledMaintenance).
      and_yield

    expect(Flapjack::Data::Check).to receive(:find_by_id!).
      with(check.id).and_return(check)

    expect(check).to receive(:invalid?).and_return(false)
    expect(check).to receive(:save!).and_return(true)

    tags = double('tags', :ids => [])
    expect(tags).to receive(:add).with(tag)
    expect(check).to receive(:tags).twice.and_return(tags)

    expect(Flapjack::Data::Tag).to receive(:find_by_ids!).with(tag.id).and_return([tag])

    expect(Flapjack::Data::Check).to receive(:jsonapi_type).and_return('check')

    patch "/checks/#{check.id}",
      Flapjack.dump_json(:data => {:id => check.id, :type => 'check', :links =>
        {:tags => {:linkage => [{:type => 'tag', :id => 'database'}]}}}),
      jsonapi_env
    expect(last_response.status).to eq(204)
  end

end
