require "test_helper"

class MqttMessagesControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get mqtt_messages_index_url
    assert_response :success
  end

  test "should get show" do
    get mqtt_messages_show_url
    assert_response :success
  end
end
