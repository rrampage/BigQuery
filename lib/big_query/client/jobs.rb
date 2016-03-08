# https://cloud.google.com/bigquery/docs/reference/v2/jobs

module BigQuery
  class Client
    module Jobs
      # Fetches a bigquery job by id
      #
      # @param id [Integer] job id to fetch
      # @param options [Hash] bigquery opts accepted
      # @return [Hash] json api response
      def job(id, opts = {})
        response = @client.get_job(
          @project_id,
          id,
          opts.deep_symbolize_keys
        )

        response.to_h.deep_stringify_keys
      end

      # lists all the jobs
      #
      # @param options [Hash] bigquery opts accepted
      # @return [Hash] json api response
      def jobs(opts = {})
        response = @client.list_jobs(
          @project_id,
          opts.deep_symbolize_keys
        )

        response.to_h.deep_stringify_keys
      end

      # Gets the results of a given job
      #
      # @param id [Integer] job id to fetch
      # @param options [Hash] bigquery opts accepted
      # @return [Hash] json api response
      def get_query_results(id, opts = {})

        response = @client.get_job_query_results(
          @project_id, id, opts.deep_symbolize_keys
        )

        response.to_h.deep_stringify_keys
      end

      # Insert a job
      #
      # @param options [Hash] hash of job options
      # @param parameters [Hash] hash of parameters (uploadType, etc.)
      # @param media [Google::APIClient::UploadIO] media upload
      # @return [Hash] json api response
      def insert_job(opts, parameters = {}, media = nil)
        _opts = opts.deep_symbolize_keys
        job_type = _opts.keys.find { |k| [:copy, :extract, :load, :query].include?(k.to_sym) }
        job_type_configuration = __send__("_#{job_type.to_s}", _opts[job_type].deep_symbolize_keys)
        job_configuration = Google::Apis::BigqueryV2::JobConfiguration.new(
          job_type.to_sym => job_type_configuration
        )
        job_configuration.dry_run = _opts[:dry_run] if _opts[:dry_run]
        job = Google::Apis::BigqueryV2::Job.new(
          configuration: job_configuration
        )
        response = @client.insert_job(
          @project_id,
          job,
          upload_source: media
        )

        response.to_h.deep_stringify_keys
      end

      private
      def _copy(opts)
        _opts = opts.dup
        if (_opts[:source_tables])
          _opts[:source_tables] = _opts[:source_tables].dup.map { |source_table| Google::Apis::BigqueryV2::TableReference.new(source_table) }
        else
          _opts[:source_table] = Google::Apis::BigqueryV2::TableReference.new(_opts[:source_table])
        end
        _opts[:destination_table] = Google::Apis::BigqueryV2::TableReference.new(_opts[:destination_tables])

        Google::Apis::BigqueryV2::JobConfigurationCopy.new(
          _opts
        )
      end

      def _extract(opts)
        _opts = opts.dup
        _opts[:source_table] = Google::Apis::BigqueryV2::TableReference.new(_opts[:source_table])
        Google::Apis::BigqueryV2::JobConfigurationExtract.new(
          _opts
        )
      end

      def _load(opts)
        _opts = opts.dup
        _opts[:destination_table] = Google::Apis::BigqueryV2::TableReference.new(_opts[:destination_table])
        _opts[:schema] = Google::Apis::BigqueryV2::TableSchema.new({ fields: normalize_schema(_opts[:schema][:fields]) })
        Google::Apis::BigqueryV2::JobConfigurationLoad.new(
          _opts
        )
      end

      def _query(opts)
        _opts = opts.dup
        Google::Apis::BigqueryV2::JobConfigurationQuery.new(
          _opts
        )
      end
    end
  end
end
