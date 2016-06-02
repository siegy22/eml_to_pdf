module EmlToPdf
  class Email
    MIME_TYPES = {
      plain_text: "text/plain",
      html: "text/html"
    }

    TEMPLATES_PATH = Pathname.new(File.expand_path(__dir__)) + "templates"

    def initialize(input_path, fallback_text)
      @mail = Mail.read(input_path)
      @fallback_text = fallback_text
    end

    def visible_attachments
      @mail.attachments.select do |attachment|
        attachment.content_id.nil?
      end
    end

    def to_html
      most_inner_parts = extract_parts(@mail)
      html = extract_html_from_parts(most_inner_parts, @fallback_text)
      html = resolve_cids_from_attachments(html, @mail.attachments)
      html = add_mail_metadata_to_html(@mail, html)
      html
    end

    private
    def resolve_cids_from_attachments(html, attachments)
      cid_list(attachments).inject(html) do |html, key_and_value|
        k, v = key_and_value
        html.gsub!(k, v)
        html
      end
    end

    def cid_list(attachments)
      @cid_list ||= attachments.inject({}) do |list, attachment|
        if attachment.content_id && attachment.content_transfer_encoding == "base64"
          mime_type = attachment.mime_type
          decoded = attachment.body.raw_source.strip.gsub(/[\n\t\r]/, "")
          content_id = "cid:" + attachment.content_id[1..-2] # remove <> from Content-ID
          list[content_id] = "data:#{mime_type};base64,#{decoded}"
        end
        list
      end
    end

    def extract_parts(mail_or_part)
      parts = mail_or_part.parts
      if parts.empty?
        [mail_or_part]
      elsif multipart_part = parts.detect(&:multipart?)
        extract_parts(multipart_part)
      else
        parts
      end
    end

    def extract_html_from_parts(parts, fallback_text)
      if (html_body = find_body_with_type(parts, :html)) && usable_html?(html_body)
        html_body
      elsif text_body = find_body_with_type(parts, :plain_text)
        wrap_text_in_html(text_body)
      else
        wrap_text_in_html(fallback_text)
      end
    end

    def find_body_with_type(parts, type)
      part = parts.detect do |part|
        part.mime_type == MIME_TYPES[type]
      end
      part.decoded if part
    end

    def wrap_text_in_html(text)
      "<!DOCTYPE html><html><head></head><body><pre>#{text}</pre></body></html>"
    end

    def add_mail_metadata_to_html(mail, html)
      context = MetadataContext.new(from: mail.from,
                                    to: mail.to,
                                    cc: mail.cc,
                                    date: mail.date,
                                    subject: mail.subject,
                                    attachments: visible_attachments)
      heading = render_template("heading.html.erb", context.get_binding)
      style = render_template("style.html")
      doc = Nokogiri::HTML(html)
      doc.at_css("body").prepend_child(heading)
      doc.at_css("head").prepend_child(style)
      doc.to_html
    end

    def render_template(filename, binding = nil)
      template = File.read(TEMPLATES_PATH + filename)
      renderer = ERB.new(template)
      renderer.result(binding)
    end

    def usable_html?(html)
      doc = Nokogiri::HTML(html)
      doc.at_css("html") && doc.at_css("head") && doc.at_css("body")
    end
  end
end
