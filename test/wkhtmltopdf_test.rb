require 'test_helper'

class WkhtmltopdfTest < MiniTest::Test
  def test_raises_if_wkhtmltopdf_fails
    error = assert_raises EmlToPdf::Wkhtmltopdf::ConversionError do
      EmlToPdf::Wkhtmltopdf.convert(broken_html, TEST_FOLDER_PATH + ".." + "tmp" + "test_out.pdf")
    end
    assert_equal(wkhtml_to_pdf_error_message, error.message)
  end

  def broken_html
    <<-HTML
      <html><img src="http://no-exist.com/asdf/blabla"></html>
    HTML
  end

  def wkhtml_to_pdf_error_message
    "sh: 1: wkhtmltopdf: not found\n"
  end
end
