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
    email = EmlToPdf::Email.new(email_fixture_path("latin1"))
    doc = Nokogiri::HTML(email.to_html)
    table = doc.at_css(".email-metadata table")
    assert_equal "De:", table.at_css("tr:nth-child(1) td:nth-child(1)").text
    assert_equal "À:", table.at_css("tr:nth-child(2) td:nth-child(1)").text
    assert_equal "Cc:", table.at_css("tr:nth-child(3) td:nth-child(1)").text
    assert_equal "Date:", table.at_css("tr:nth-child(4) td:nth-child(1)").text
    assert_equal "1970", table.at_css("tr:nth-child(4) td:nth-child(2)").text
  end

  def test_custom_wkhtml2pdf
    EmlToPdf.configure do |config|
      config.wkhtmltopdf = '/my_custom_path/wkhtmltopdf'
    end

    mock = MiniTest::Mock.new
    mock.expect(:call, nil, ["/my_custom_path/wkhtmltopdf --encoding utf-8 --footer-center [page] --footer-spacing 2.5 --quiet - output_path 2>&1", 'r+'])
    IO.stub(:popen, mock) do
      EmlToPdf::Wkhtmltopdf.convert('input_path', 'output_path')
    end
    mock.verify
  end
end
