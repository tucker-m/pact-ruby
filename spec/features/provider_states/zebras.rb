require 'json'
require 'fileutils'

Pact.provider_states_for 'the-wild-beast-store' do

  provider_state :the_zebras_are_here do
    set_up do
      FileUtils.mkdir_p 'tmp'
      some_data = [{'name' => 'Jason'},{'name' => 'Sarah'}]
      File.open("tmp/a_mock_database.json", "w") { |file| file << some_data.to_json }
    end

    tear_down do
      FileUtils.rm_rf("tmp/a_mock_database.json")
    end
  end
end

Pact.provider_state "some other zebras are here" do
  set_up do
    some_data = [{'name' => 'Mark'},{'name' => 'Gertrude'}]
    File.open("tmp/a_mock_database.json", "w") { |file| file << some_data.to_json }
    send_to_call ({"HTTP_AUTHORIZATION" => "password"})
  end

  tear_down do
    FileUtils.rm_rf("tmp/a_mock_database.json")
  end
end
