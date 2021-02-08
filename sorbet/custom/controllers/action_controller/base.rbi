# typed: strong
class ActionController::Base
  sig { params(except: T.any(T::Array[Symbol],Symbol)).void }
  def self.verify_authorized(except: nil); end
end
