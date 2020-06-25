module EmlToPdf
  class Configuration
    attr_accessor :from_label, :to_label, :cc_label, :date_label, :wkhtmltopdf, :timeout

    def initialize
      @from_label = "From"
      @to_label = "To"
      @cc_label = "Cc"
      @date_label = "Date"
      @date_format = lambda { |date| date.strftime("%Y-%m-%d %H:%M:%S %z") }
      @wkhtmltopdf = 'wkhtmltopdf'
      @timeout = 0
    end

    def date_format(&block)
      if block_given?
        @date_format = block
      else
        @date_format
      end
    end

    def format_date(date)
      @date_format.call(date)
    end
  end
end
