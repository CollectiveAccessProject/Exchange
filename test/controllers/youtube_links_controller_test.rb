require 'test_helper'

class YoutubeLinksControllerTest < ActionController::TestCase
  setup do
    @youtube_link = youtube_links(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:youtube_links)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create youtube_link" do
    assert_difference('YoutubeLink.count') do
      post :create, youtube_link: { key: @youtube_link.key, original_link: @youtube_link.original_link }
    end

    assert_redirected_to youtube_link_path(assigns(:youtube_link))
  end

  test "should show youtube_link" do
    get :show, id: @youtube_link
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @youtube_link
    assert_response :success
  end

  test "should update youtube_link" do
    patch :update, id: @youtube_link, youtube_link: { key: @youtube_link.key, original_link: @youtube_link.original_link }
    assert_redirected_to youtube_link_path(assigns(:youtube_link))
  end

  test "should destroy youtube_link" do
    assert_difference('YoutubeLink.count', -1) do
      delete :destroy, id: @youtube_link
    end

    assert_redirected_to youtube_links_path
  end
end
