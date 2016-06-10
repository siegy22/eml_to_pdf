require 'test_helper'

class WkhtmltopdfTest < MiniTest::Test
  def test_raises_if_wkhtmltopdf_fails
    EmlToPdf::Wkhtmltopdf.convert(broken_html, TEST_FOLDER_PATH + ".." + "tmp" + "test_out.pdf")
  rescue EmlToPdf::Wkhtmltopdf::ConversionError => e
    assert_equal wkhtml_to_pdf_error_message, e.message

  end

  def broken_html
    <<-HTML
      <html><img src="http://no-exist.com/asdf/blabla"></html>
    HTML
  end

  def wkhtml_to_pdf_error_message
    "Loading pages (1/6)\n[>                                                           ] 0%\r[======>                                                     ] 10%\r[==============================>                             ] 50%\r[============================================================] 100%\rCounting pages (2/6)                                               \n[============================================================] Object 1 of 1\rResolving links (4/6)                                                       \n[============================================================] Object 1 of 1\rLoading headers and footers (5/6)                                           \nPrinting pages (6/6)\n[>                                                           ] Preparing\r[============================================================] Page 1 of 1\rDone                                                                      \nExit with code 1 due to network error: HostNotFoundError\n"
  end
end
