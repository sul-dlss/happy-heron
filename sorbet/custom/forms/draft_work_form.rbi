 # typed: strong

class DraftWorkForm
  sig { returns(T.any(Date, EDTF::Interval)) }
  def created_edtf; end
end
