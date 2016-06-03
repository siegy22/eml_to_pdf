require 'pathname'

module EmlToPdf
  class Email
    MIME_TYPES = {
      plain_text: "text/plain",
      html: "text/html",
      multipart_mixed: "multipart/mixed",
      multipart_alternative: "multipart/alternative"
    }

    TEMPLATES_PATH = Pathname.new(File.expand_path(__dir__)) + "templates"

    def initialize(input_path, fallback_text)
      @mail = Mail.read(input_path)
      @fallback_text = fallback_text
    end

    def visible_attachments
      @mail.attachments.select do |attachment|
        !attachment.inline?
      end
    end

    def to_html
      html = html_body(@mail).join
      html = resolve_cids_from_attachments(html, @mail.attachments)
      html = add_mail_metadata_to_html(@mail, html)
      html
    end

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
          list[attachment.url] = "data:#{mime_type};base64,#{decoded}"
        end
        list
      end
    end

    def html_body(mail_or_part)
      if multipart_alternative?(mail_or_part)
        [extract_best_representation_from_parts(mail_or_part.parts)]
      elsif multipart_mixed?(mail_or_part)
        mail_or_part.parts.map do |part|
          html_body(part)
        end
      else
        [extract_best_representation_from_parts(Array(mail_or_part))]
      end.flatten
    end

    def extract_best_representation_from_parts(parts)
      if html_part = find_body_with_type(parts, :html)
        html_part.decoded
      elsif text_part = find_body_with_type(parts, :plain_text)
        wrap_text_in_pre_tag(text_part.decoded)
      elsif multipart_part = find_body_with_type(parts, :multipart_mixed)
        html_body(multipart_part)
      else
        ""
      end
    end

    def find_body_with_type(parts, type)
      parts.detect do |part|
        part.mime_type == MIME_TYPES[type]
      end
    end

    def multipart_mixed?(part)
      part.mime_type == MIME_TYPES[:multipart_mixed]
    end

    def multipart_alternative?(part)
      part.mime_type == MIME_TYPES[:multipart_alternative]
    end


    def wrap_text_in_html(text)
      "<!DOCTYPE html><html><head></head><body><pre>#{text}</pre></body></html>"
    end

    def wrap_text_in_pre_tag(text)
      "<pre>#{text}</pre>"
    end

    def add_mail_metadata_to_html(mail, html)
      context = MetadataContext.new(from: save_extract_header(mail, :from),
                                    to: save_extract_header(mail, :to),
                                    cc: save_extract_header(mail, :cc),
                                    date: mail.date,
                                    subject: mail.subject,
                                    attachments: visible_attachments)
      heading = render_template("heading.html.erb", context.get_binding)
      style = render_template("style.html")
      html = "<body></body>" if html.empty?
      p html
      doc = Nokogiri::HTML(html)
      doc.at_css("body").prepend_child(heading)
      doc.at_css("body").prepend_child(style)
      doc.to_html
    end

    def render_template(filename, binding = nil)
      template = File.read(TEMPLATES_PATH + filename)
      renderer = ERB.new(template)
      renderer.result(binding)
    end

    def save_extract_header(mail, header)
      if header = mail.header[header]
        header.decoded
      else
        ""
      end
    end
  end
end
