# frozen_string_literal: true

module CocinaGenerator
  module Description
    # This generates Events for a work
    class EventsGenerator
      def self.generate(work_version:)
        new(work_version:).generate
      end

      def initialize(work_version:)
        @work_version = work_version
      end

      def generate
        deposit_events + Array(created_date_event) + Array(published_date_event)
      end

      private

      attr_reader :work_version

      def published_date_event
        event_for_date(date: work_version.published_edtf, event_type: 'publication', date_type: 'publication',
                       primary: true)
      end

      def created_date_event
        event_for_date(date: work_version.created_edtf, event_type: 'creation', date_type: 'creation')
      end

      def deposit_events
        return [] if deposit_versions.blank?

        Array(deposit_publication_event) + deposit_modification_events
      end

      def deposit_publication_event
        event_for_work_version(work_version: deposit_publication_version, event_type: 'deposit',
                               date_type: 'publication')
      end

      def deposit_modification_events
        deposit_modification_versions.map do |deposit_version|
          event_for_work_version(work_version: deposit_version, event_type: 'deposit', date_type: 'modification')
        end
      end

      def deposit_versions
        # Treating this version as a deposit version
        @deposit_versions ||= work_version.work.work_versions.filter do |check_work_version|
          check_work_version.deposited? || check_work_version == work_version
        end
      end

      def deposit_publication_version
        deposit_versions.first
      end

      def deposit_modification_versions
        deposit_versions.slice(1..-1)
      end

      def event_for_date(date:, event_type:, date_type:, primary: false)
        return unless date

        Cocina::Models::Event.new({
                                    type: event_type,
                                    date: [DateGenerator.generate(date:, type: date_type, primary:)]
                                  })
      end

      def event_for_work_version(work_version:, event_type:, date_type:)
        date = work_version.published_at || work_version.updated_at
        event_for_date(date:, event_type:, date_type:)
      end
    end
  end
end
