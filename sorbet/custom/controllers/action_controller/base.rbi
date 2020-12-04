# typed: strong
class ActionController::Base
  sig { params(except: T::Array[Symbol]).void }
  def self.verify_authorized(except: nil); end
end
