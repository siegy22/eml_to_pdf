module EmlToPdf
  class Configuration
    attr_accessor :from_label, :to_label, :cc_label, :date_label
    attr_reader :date_format

    def initialize
      @from_label = "From"
      @to_label = "To"
      @cc_label = "Cc"
      @date_label = "Date"
      @date_format = "%Y-%m-%d %H:%M:%S %z"
    end

    def date_format=(value)
      if value.is_a?(String)
        @date_format = value
      else
        raise ArgumentError, "You can only use a String to format the date. (See Date#strftime)"
      end
    end
  end
end
