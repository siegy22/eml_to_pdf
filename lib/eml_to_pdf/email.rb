require 'pathname'

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
        !attachment.inline?
      end
    end

    def to_html
      html = extract_html_part(@mail, @fallback_text)
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
          list[attachment.url] = "data:#{mime_type};base64,#{decoded}"
        end
        list
      end
    end

    def extract_html_part(mail, fallback)
      if html_part = mail.html_part
        html_part.decoded
      elsif text_part = mail.text_part
        wrap_text_in_html(text_part.decoded)
      else
        wrap_text_in_html(fallback)
      end
    end

    def wrap_text_in_html(text)
      "<!DOCTYPE html><html><head></head><body><pre>#{text}</pre></body></html>"
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
