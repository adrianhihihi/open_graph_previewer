require "test_helper"

class OgPreviewerControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get og_previewer_index_url
    assert_response :success
  end
end
