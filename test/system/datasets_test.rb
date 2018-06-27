# frozen_string_literal: true

require "application_system_test_case"

# Test dataset pages.
class DatasetsTest < ApplicationSystemTestCase
  test "visiting the index" do
    visit datasets_url
    screenshot("visit-datasets-index")
    page.execute_script("window.scrollBy(0, $(\"body\").height());")
    screenshot("visit-datasets-index")
  end
end
