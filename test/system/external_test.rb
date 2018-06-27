# frozen_string_literal: true

require "application_system_test_case"

# Test external pages.
class ExternalTest < ApplicationSystemTestCase
  test "visiting the about page" do
    visit about_url
    screenshot("visit-about-page")
    page.execute_script("window.scrollBy(0, $(\"body\").height());")
    screenshot("visit-about-page")
  end

  test "visit demo page" do
    visit demo_url
    screenshot("visit-demo-page")
    find("a[href='#download-data']").click
    sleep(0.5) # Allow time to scroll
    screenshot("visit-demo-page")
    find("a[href='#statistics']").click
    sleep(0.5) # Allow time to scroll
    screenshot("visit-demo-page")
    find("a[href='#extract-edf-signal']").click
    sleep(0.5) # Allow time to scroll
    screenshot("visit-demo-page")
    page.execute_script("window.scrollBy(0, $(\"body\").height());")
    screenshot("visit-demo-page")
  end

  test "visiting the team page" do
    visit team_url
    screenshot("visit-team-page")
  end

  test "visiting the aug page" do
    visit aug_url
    screenshot("visit-aug-page")
  end

  test "visiting the past contributors page" do
    visit contributors_url
    screenshot("visit-past-contributors-page")
  end

  test "visiting the data sharing language page" do
    visit datasharing_url
    screenshot("visit-data-sharing-language-page")
  end

  test "visiting the fair page" do
    visit fair_url
    screenshot("visit-fair-page")
  end

  test "visiting the share page" do
    visit share_url
    screenshot("visit-share-page")
  end

  test "visiting the contact page" do
    visit contact_url
    sleep(0.5) # Allow time for map to load
    screenshot("visit-contact-page")
  end

  test "visit blog" do
    visit blog_url
    screenshot("visit-blog")
    assert_selector "h1", text: "Blog"
    # Add if blog extends beyond bottom of browser.
    # page.execute_script("window.scrollBy(0, $(\"body\").height());")
    # screenshot("visit-blog")
  end

  test "visit forum" do
    visit topics_url
    screenshot("visit-forum")
    assert_selector "h1", text: "Forum"
    # Add if forum extends beyond bottom of browser.
    # page.execute_script("window.scrollBy(0, $(\"body\").height());")
    # screenshot("visit-forum")
  end

  test "visiting the sitemap" do
    visit sitemap_url
    screenshot("visit-sitemap")
    # Add if sitemap extends beyond bottom of browser.
    # page.execute_script("window.scrollBy(0, $(\"body\").height());")
    # screenshot("visit-sitemap")
  end

  test "visiting the version page" do
    visit version_url
    screenshot("visit-version-page")
  end

  test "visiting the voting guidelines page" do
    visit voting_url
    screenshot("visit-voting-guidelines-page")
  end
end
