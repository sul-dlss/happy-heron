# frozen_string_literal: true

module CocinaGenerator
  module Description
    # Generator for Cocina dates encoded as EDTF
    class DateGenerator
      # @param [EDTF::*|ActiveSupport::TimeWithZone] date
      # @param [type] type for date
      # @param [boolean] primary - whether status is primary
      # @return [Hash] the props for the date
      def self.generate(date:, type: nil, primary: false)
        new(date:, type:, primary:).generate
      end

      def initialize(date:, type:, primary:)
        @date = date
        @type = type
        @primary = primary
      end

      def generate
        {
          encoding: { code: 'edtf' },
          type:,
          status: primary ? 'primary' : nil
        }.compact.merge(date_props)
      end

      private

      attr_reader :date, :type, :primary

      def date_props
        case @date
        when EDTF::Interval
          interval_props(date)
        when ActiveSupport::TimeWithZone
          time_with_zone_props(date)
        else
          edtf_date_props(date)
        end
      end

      def interval_props(interval_date)
        {
          structuredValue: interval_structured_values(interval_date)
        }.tap do |props|
          if interval_date.from&.uncertain? || interval_date.to&.uncertain?
            props[:qualifier] = 'approximate'
            props[:structuredValue].each { |struct_date_val| struct_date_val.delete(:qualifier) }
          end
        end.compact
      end

      def interval_structured_values(interval_date)
        [].tap do |structured_values|
          structured_values << edtf_date_props(interval_date.from, type: 'start') if interval_date.from
          structured_values << edtf_date_props(interval_date.to, type: 'end') if interval_date.to
        end
      end

      def edtf_date_props(edtf_date, type: nil)
        {
          qualifier: edtf_date.uncertain? ? 'approximate' : nil,
          value: edtf_date.edtf.chomp('?'),
          type:
        }.compact
      end

      def time_with_zone_props(zone_date)
        {
          value: zone_date.strftime('%Y-%m-%d')
        }
      end
    end
  end
end
