require 'pathname'

module EmlToPdf
  class Email
    MIME_TYPES = {
      plain_text: "text/plain",
      html: "text/html",
      multipart_mixed: "multipart/mixed"
    }

    TEMPLATES_PATH = Pathname.new(File.expand_path(__dir__)) + "templates"

    def initialize(input_path)
      @input_path = input_path
      @mail = Mail.read(input_path)
    end

    def to_html
      html = text_parts(@mail).join
      html = resolve_cids_from_attachments(html, @mail.attachments)
      html = add_mail_metadata_to_html(@mail, html)
      html
    end

    def text_parts(mail_or_part)
      if mail_or_part.multipart?
        parts = mail_or_part.parts
        if mail_or_part.mime_type == MIME_TYPES[:multipart_alternative]
          text_parts(extract_best_representation_from_parts(parts))
        else
          parts.map do |part|
            text_parts(part)
          end
        end
      else
        best_part = if mail_or_part.mime_type == MIME_TYPES[:plain_text] && !mail_or_part.attachment?
                      wrap_text_in_pre_tag(mail_or_part.decoded)
                    elsif mail_or_part.mime_type == MIME_TYPES[:html] && !mail_or_part.attachment?
                      mail_or_part.decoded
                    else
                      ""
                    end
        [best_part]
      end.flatten
    end

    private
    def visible_attachments(mail)
      mail.attachments.select do |attachment|
        !attachment.inline?
      end
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
      if multipart_part = parts.detect(&:multipart?)
        multipart_part
      elsif html_part = find_body_with_type(parts, :html)
        html_part
      elsif text_part = find_body_with_type(parts, :plain_text)
        text_part
      else
        "can't find useable part"
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
      part.mime_type == MIME_TYPES[:multipart_alternative] || part.mime_type == MIME_TYPES[:multipart_related]
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
                                    attachments: visible_attachments(mail))
      heading = render_template("heading.html.erb", context.get_binding)
      style = render_template("style.html")
      html = "<body></body>" if html.empty?
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
