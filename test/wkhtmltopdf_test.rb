require 'test_helper'

class WkhtmltopdfTest < MiniTest::Test
  def test_raises_if_wkhtmltopdf_fails
    error = assert_raises EmlToPdf::Wkhtmltopdf::ConversionError do
      EmlToPdf::Wkhtmltopdf.convert(broken_html, TEST_FOLDER_PATH + ".." + "tmp" + "test_out.pdf")
    end
    assert_equal("Exit with code 1 due to network error: HostNotFoundError\n", error.message)
  end

  def test_raises_if_wkhtmltopdf_binary_is_not_found
    EmlToPdf.configure { |config| config.wkhtmltopdf = '/bin/shouldnexist' }
    error = assert_raises EmlToPdf::Wkhtmltopdf::ConversionError do
      EmlToPdf::Wkhtmltopdf.convert(broken_html, TEST_FOLDER_PATH + ".." + "tmp" + "test_out.pdf")
    end
    assert_includes(error.message, "/bin/shouldnexist")
  end

  def broken_html
    <<-HTML
      <html><img src="http://no-exist.com/asdf/blabla"></html>
    HTML
  end
end
