require 'test_helper'

class TestEmail < MiniTest::Test
  def test_ascii_7bit
    email = EmlToPdf::Email.new(email_fixture_path("ascii_7bit"))
    assert_equal(fixture("ascii_7bit.html", :html), email.to_html)
  end

  def test_attachment
    email = EmlToPdf::Email.new(email_fixture_path("attachment"))
    assert_equal(fixture("attachment.html", :html), email.to_html)
  end

  def test_broken_meta_tags
    email = EmlToPdf::Email.new(email_fixture_path("broken_meta_tags"))
    assert_equal(fixture("broken_meta_tags.html", :html), email.to_html)
  end

  def test_cid
    email = EmlToPdf::Email.new(email_fixture_path("cid"))
    assert_equal(fixture("cid.html", :html), email.to_html)
  end

  def test_encoded_word_without_lwsp
    email = EmlToPdf::Email.new(email_fixture_path("encoded_word_without_lwsp"))
    assert_equal(fixture("encoded_word_without_lwsp.html", :html), email.to_html)
  end

  def test_from_header_with_quotes
    email = EmlToPdf::Email.new(email_fixture_path("from_header_with_quotes"))
    assert_equal(fixture("from_header_with_quotes.html", :html), email.to_html)
  end

  def test_fwd_attachment
    email = EmlToPdf::Email.new(email_fixture_path("fwd_attachment"))
    assert_equal(fixture("fwd_attachment.html", :html), email.to_html)
  end

  def test_invalid_date
    email = EmlToPdf::Email.new(email_fixture_path("invalid_date"))
    assert_equal(fixture("invalid_date.html", :html), email.to_html)
  end

  def test_latin1
    email = EmlToPdf::Email.new(email_fixture_path("latin1"))
    assert_equal(fixture("latin1.html", :html), email.to_html)
  end

  def test_latin1_multipart
    email = EmlToPdf::Email.new(email_fixture_path("latin1_multipart"))
    assert_equal(fixture("latin1_multipart.html", :html), email.to_html)
  end

  def test_multipart_text
    email = EmlToPdf::Email.new(email_fixture_path("multipart_text"))
    assert_equal(fixture("multipart_text.html", :html), email.to_html)
  end

  def test_multiple_html_parts
    email = EmlToPdf::Email.new(email_fixture_path("multiple_html_parts"))
    assert_equal(fixture("multiple_html_parts.html", :html), email.to_html)
  end

  def test_nested_attachments
    email = EmlToPdf::Email.new(email_fixture_path("nested_attachments"))
    assert_equal(fixture("nested_attachments.html", :html), email.to_html)
  end

  def test_nested_html_attachment
    email = EmlToPdf::Email.new(email_fixture_path("nested_html_attachment"))
    assert_equal(fixture("nested_html_attachment.html", :html), email.to_html)
  end

  def test_nested_referenced_image_attachment
    email = EmlToPdf::Email.new(email_fixture_path("nested_referenced_image_attachment"))
    assert_equal(fixture("nested_referenced_image_attachment.html", :html), email.to_html)
  end

  def test_resent
    email = EmlToPdf::Email.new(email_fixture_path("resent"))
    assert_equal(fixture("resent.html", :html), email.to_html)
  end

  def test_time_zone_dates
    email = EmlToPdf::Email.new(email_fixture_path("time_zone_dates"))
    assert_equal(fixture("time_zone_dates.html", :html), email.to_html)
  end

  def test_utf8
    email = EmlToPdf::Email.new(email_fixture_path("utf8"))
    assert_equal(fixture("utf8.html", :html), email.to_html)
  end

  def test_xxs_mail
    email = EmlToPdf::Email.new(email_fixture_path("xxs_mail"))
    assert_equal(fixture("xxs_mail.html", :html), email.to_html)
  end
end
