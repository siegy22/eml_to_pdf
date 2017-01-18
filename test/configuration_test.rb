require 'test_helper'

class ConfigurationTest < MiniTest::Test
  def teardown
    super
    EmlToPdf.reset_configuration!
  end

  def test_basic_configuration
    example_to_label = "Who to:"
    EmlToPdf.configure do |config|
      config.to_label = example_to_label
    end
    assert_equal example_to_label, EmlToPdf.configuration.to_label
  end

  def test_output_with_config
    # French setup
    EmlToPdf.configure do |config|
      config.from_label = "De:"
      config.to_label = "À:"
      config.cc_label = "Cc:"
      config.date_label = "Date:"
      config.date_format do |date|
        date.strftime("%Y")
      end
    end
    table = metadata_table
    assert_equal "De:", table.at_css("tr:nth-child(1) td:nth-child(1)").text
    assert_equal "À:", table.at_css("tr:nth-child(2) td:nth-child(1)").text
    assert_equal "Cc:", table.at_css("tr:nth-child(3) td:nth-child(1)").text
    assert_equal "Date:", table.at_css("tr:nth-child(4) td:nth-child(1)").text
    assert_equal "1970", table.at_css("tr:nth-child(4) td:nth-child(2)").text
  end

  def test_no_output_with_config
    EmlToPdf.configure do |config|
      config.metadata_visible = false
    end

    table = metadata_table

    assert_nil table
  end

  def metadata_table
    email = EmlToPdf::Email.new(email_fixture_path("latin1"))
    doc = Nokogiri::HTML(email.to_html)
    doc.at_css(".email-metadata table")
  end
end
