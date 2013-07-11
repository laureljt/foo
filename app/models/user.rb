class User < ActiveRecord::Base
  belongs_to :customer
  has_many :orders
  
  scope :normal, where("(admin is null OR admin = false) AND (employee is null OR employee = false)")
  scope :admins, where(:admin => true)
  scope :employees, :conditions => { :employee => true }
  scope :ordered, joins(:customer).order("customers.last_name", "customers.first_name")
  
  attr_accessor :first_name
  attr_accessor :last_name  

  attr_accessible :email  

  attr_protected :admin
  attr_protected :employee
  attr_protected :customer_id
  
  before_save { generate_token(:auth_token)     }
  before_save { generate_token(:remember_token) }  
  before_validation :downcase_email
  
  EMAIL_REGEX = /^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}$/i

  validates_presence_of :first_name, :last_name, :on => :create
  validates :email, :uniqueness => true, :format => {:with => EMAIL_REGEX}
  validates :password, :presence => true, :length => { :minimum => 5 }, :confirmation => true, :on => :create
  
  def update_info(info)
    self.email = info[:email] unless info[:email].blank?
    unless info[:password].blank? || info[:password].size < 5    
      self.password = info[:password]
    else
      @error_message = "BAD"
    end
    self.save
  end
  
  def make_a_customer
    customer = Customer.create(:first_name => self.first_name, :last_name => self.last_name, :email => self.email)
    self.customer_id = customer.id
    self.save
  end
  
  def self.email_matches(value)
    where("email=?", value)
  end  

  def User.current_user=(new_user)
    Thread.current[:current_user] = new_user
  end
  
  def send_password_reset
    generate_token(:password_reset_token)
    self.password_reset_sent_at = Time.zone.now
    save!
    Notifier.password_reset(self).deliver
  end

  def generate_token(column)
    begin
      self[column] = SecureRandom.urlsafe_base64
    end while User.exists?(column => self[column])
  end

  def User.current_user
    Thread.current[:current_user]
  end

  def password=(password)
    return nil if password.blank?
    @password = password
    self.password_salt = BCrypt::Engine.generate_salt
    self.password_hash = BCrypt::Engine.hash_secret(password, password_salt)
  end

  def password
    @password
  end

  def password?(password)
    BCrypt::Engine.valid_salt?(password_salt) && password_hash == BCrypt::Engine.hash_secret(password, password_salt)
  end

  def self.sudo
    old_current_user = User.current_user
    begin
      User.current_user = User.find(SYSTEM_UID)
      yield
    ensure
      User.current_user = old_current_user
    end
  end

  def self.[](user_name)
    user_name_matches(user_name).first
  end 
  
  def make_admin 
    self.admin = true
    self.save
  end      

  def remove_admin 
    self.admin = false
    self.save
  end      
  
  def make_employee 
    self.employee = true
    self.save
  end      
  
  def remove_employee 
    self.employee = false
    self.save
  end      
  
  def self.admin?
    self.admin == true
  end

  def self.employee?
    self.employee == true
  end
  
  def downcase_email
    self.email = self.email.downcase if self.email.present?
  end
end
