class Ahoy::Store < Ahoy::Stores::ActiveRecordStore
  # customize here
  def exclude?
    bot? || current_user.id == 1
  end
end
