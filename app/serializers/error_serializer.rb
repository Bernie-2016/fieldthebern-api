class ErrorSerializer
  def self.serialize(error)
    { errors: serialize_error(error) }
  end

  def self.serialize_error(error)
    return serialize_argument_error(error) if error.class == ArgumentError
    return serialize_record_not_found_error(error) if error.class == ActiveRecord::RecordNotFound
  end

  def self.serialize_argument_error(error)
    {
      id: "ARGUMENT_ERROR",
      title: "Argument error",
      detail: error.message,
      status: 422
    }
  end

  def self.serialize_record_not_found_error(error)
    return {
      id: "RECORD_NOT_FOUND",
      title: "Record not found",
      detail: error.message,
      status: 404
    }
  end
end
