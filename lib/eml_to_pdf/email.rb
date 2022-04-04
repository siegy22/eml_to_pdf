require "pathname"
require "nokogiri"
require "mail"
require "erb"
require "tempfile"

module EmlToPdf
  class Email
    TEMPLATES_PATH = Pathname.new(File.expand_path(__dir__)) + "templates"
        VALID_ATTACHMENT_FORMAT = [
      'text/plain',
      'message/rfc822',
      'pdf',
      #'eml',
      'image/tiff',
      'tiff',
      'image/tif',
      'tif',
      'vnd.ms-excel',
      'vnd.openxmlformats-officedocument.spreadsheetml.sheet',
      'doc',
      'docx',
      'msg',
      'octet-stream',
      'msword',
      'rtf',
      'vndopenxmlformats-officedocumentwordprocessingmldocument',
      'vnd.openxmlformats-officedocument.wordprocessingml.document',
      'vnd.ms-outlook',
      'ppt',
      'vnd.ms-powerpoint',
      'pptx',
      'vnd.openxmlformats-officedocument.presentationml.presentation'
    ]
    def initialize(input_path, download_files = true)
      @input_path = input_path
      @mail = Mail.read(input_path)
      @download_files = download_files
    end

    def attachments
      @mail.attachments
    end

    def parts
      @mail.parts
    end

    def mail_object
      @mail
    end

    def to_html
      extraction = ExtractionStep.new(@mail)
      until extraction.finished?
        extraction = extraction.next
      end

      html = extraction.to_html
      html = resolve_cids_from_attachments(html, @mail.all_parts)
      html = add_mail_metadata_to_html(@mail, html)
      download_attachments(@mail) if @download_files
      html
    end

    def extract_emls
      ExtractionStep.new(@mail, @input_path).build_emls(@mail)
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
    def download_attachments(mail)
      path = File.dirname(@input_path)
      input_filename = File.basename(@input_path, ".*")
      mail.attachments.each do |attachment|
        if VALID_ATTACHMENT_FORMAT.include?(attachment.mime_type.split('application/').join(""))
          File.open("#{path}/#{input_filename}-#{attachment.filename.gsub(/\s+/, "")}", 'wb') do |f|
            f.write(attachment.decoded)
          end
        end
      end
    end

    def download_attachment(attachment)
      path = File.dirname(@input_path)
      input_filename = File.basename(@input_path, ".*")
      file_name = "#{path}/#{input_filename}-#{attachment.filename.gsub(/\s+/, "")}"
      if VALID_ATTACHMENT_FORMAT.include?(attachment.mime_type.split('application/').join(""))
        File.open(file_name, 'wb') do |f|
          f.write(attachment.decoded)
        end
      end
      file_name
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
      (mail.header[header] && mail.header[header].decoded) || ""
    end
  end
end
