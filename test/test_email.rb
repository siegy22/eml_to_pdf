require 'test_helper'

class ConverterTest < MiniTest::Test
  def test_multipart_text_email
    email = EmlToPdf::Email.new(email_fixture_path("multipart_text"), "fallback right here")
    assert_equal fixture("multipart_text_output.html", :html), email.to_html
  end

  def test_multipart_html_email
    email = EmlToPdf::Email.new(email_fixture_path("multipart_html"), "fallback right here")
    assert_equal fixture("multipart_html_output.html", :html), email.to_html
  end
end
