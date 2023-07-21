module Forms
  class ContactEmail < Base
    attr_accessor :id
    attr_accessor :email
    attr_accessor :emailable
    attr_accessor :_destroy

    validates :email, presence: true

    def main_model
      contact_email
    end

    def contact_email
      @contact_email ||= begin
        contact_email = if id.present?
          ::ContactEmail.find(id)
        else
          ::ContactEmail.new
        end
        contact_email.email = email
        contact_email.emailable = emailable
        contact_email
      end
    end

    def self.new_from_model(contact_email)
      new(id: contact_email.id,
        emailable: contact_email.emailable,
        email: contact_email.email)
    end
  end
end
