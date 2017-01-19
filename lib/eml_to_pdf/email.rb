require "pathname"
require "nokogiri"
require "mail"
require "erb"

module EmlToPdf
  class Email
    TEMPLATES_PATH = Pathname.new(File.expand_path(__dir__)) + "templates"

    def initialize(input_path)
      @input_path = input_path
      @mail = Mail.read(input_path)
    end

    def to_html
      extraction = ExtractionStep.new(@mail)
      extraction = extraction.next until extraction.finished?
      html = extraction.to_html
      html = resolve_cids_from_attachments(html, @mail.all_parts)
      html = add_mail_metadata_to_html(@mail, html) if display_metadata?
      html
    end

    private
    def visible_attachments(mail)
      mail.attachments.select do |attachment|
        !attachment.inline?
      end
    end

    def resolve_cids_from_attachments(html, attachments)
      cid_list(attachments).inject(html) do |html_text, key_and_value|
        k, v = key_and_value
        html_text.gsub!(k, v)
        html_text
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
      if doc.at_css("body").first_element_child.nil?
        doc.at_css("body").add_child(heading)
      else
        doc.at_css("body").first_element_child.add_previous_sibling(heading)
      end
      doc.at_css("body").first_element_child.add_previous_sibling(style)
      doc.to_html
    end

    def render_template(filename, binding = nil)
      template = File.read(TEMPLATES_PATH + filename)
      renderer = ERB.new(template)
      renderer.result(binding)
    end

    def save_extract_header(mail, header)
      (mail.header[header] && mail.header[header].decoded) || ""
    end

    def display_metadata?
      EmlToPdf.configuration.metadata_visible
    end
  end
end
