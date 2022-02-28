require 'combine_pdf'

module EmlToPdf
  class Converter
    def initialize(input_path, output_path, combine_pdf = false)
      @input_path = input_path
      @output_path = output_path
      @combine_pdf = combine_pdf
    end

    def convert
      email = Email.new(@input_path, !@combine_pdf)
      html = email.to_html
      Wkhtmltopdf.convert(html, temp_pdf_file_path)
      if @combine_pdf
        combine_pdfs(temp_pdf_file_path)
        if any_application_attachments?(email.parts)
          email.attachments.each do |attachement|
            combine_pdfs(email.send(:download_attachment, attachement)) unless attachement.inline?
          end
        end
      end
    end

    def any_application_attachments?(parts)
      parts.detect{|part| part.content_type.include?('application/')}
    end

    def convert_all
      convert # convert initial email content
      email = Email.new(@input_path)
      email.extract_emls.each do |eml|
        self.class.new(eml, eml.gsub('.eml', '.pdf'), @combine_pdf).convert
      end
      
    end

    def combine_pdfs(pdf_file_path)
      combined_file = File.exist?(@output_path) ? CombinePDF.load(@output_path) : CombinePDF.new
      combined_file << CombinePDF.load(pdf_file_path)
      combined_file.save @output_path
    end

    private

    def output_dir
      @output_dir ||= File.dirname(@output_path)
    end

    def temp_pdf_file_path
      @final_combined_file ||= "#{output_dir}/#{Time.now.to_i}.pdf"
    end
  end
end
