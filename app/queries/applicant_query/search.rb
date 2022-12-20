# frozen_string_literal: true

module ApplicantQuery
  class Search
    include BaseQuery

    attr_reader :params

    def initialize(job, params)
      @job    = job
      @params = params
    end

    def call
      find_applicants
      filter_by_name
      filter_by_status
      pagination
    end

    private

    def find_applicants
      @records = @job.users.includes([avatar_attachment: :blob])
    end

    def filter_by_name
      @records = @records.filter_by_name(params[:name]) if params[:name].present?
    end

    def filter_by_status
      @records = @records.filter_by_status(params[:status]) if params[:status].present?
    end

    def pagination
      @records.paginate(page: params[:page], per_page: 30)
    end
  end
end
