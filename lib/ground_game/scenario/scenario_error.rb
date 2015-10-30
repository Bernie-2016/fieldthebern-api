class ScenarioError
  def initialize(error)
    @hash = ErrorSerializer.serialize(error)
  end

  def hash
    @hash
  end

  def id
    first_error_in_hash[:id]
  end

  def title
    first_error_in_hash[:title]
  end

  def detail
    first_error_in_hash[:detail]
  end

  def status
    first_error_in_hash[:status]
  end

  private
    def first_error_in_hash
      @hash[:errors].first
    end
end
