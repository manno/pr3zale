class SoldProduct < ActiveRecord::Base
  belongs_to :product
  belongs_to :order, touch: true
  belongs_to :event
  belongs_to :user
  before_create :randomize_id
  before_create :able_to_sell_product?
  before_create :ensure_verification_token
  scope :open_orders, -> {with_state(:reserved)}
  scope :paid_orders, -> {with_state([:downloadable, :issued])}
  scope :unissued_orders, -> {with_state([:downloadable])}
  scope :issued_orders, -> {with_state(:issued)}
  scope :repaid_products, -> {with_state(:repaid)}
  scope :canceled_products, -> {with_state(:canceled)}

  def ensure_verification_token
    if verification_token.blank?
      self.verification_token = generate_verification_token
    end
  end

  def generate_verification_token
    loop do
      token = Devise.friendly_token
      break token unless SoldProduct.where(verification_token: token).first
    end
  end

  def able_to_sell_product?
    self.product.available_count > 0 and not self.product.inactive
  end

  def name
    former_product.name
  end

  def price
    return 0.0 if self.canceled?
    former_product.price
  end

  def tax
    former_product.tax
  end

  def tax_price
    return 0.0 if self.canceled?
    (1-(100/(former_product.tax+100))) * former_product.price
  end

  def description
    former_product.description
  end

  def former_product
    Rails.cache.fetch([self, "former_product"]) {self.product.version_at(self.created_at)}
  end

  def qr(url)
    if @qr.nil?
      for i in 1..15
        begin
          return @qr = RQRCode::QRCode.new(url, size: i, :level => :h )
        rescue RQRCode::QRCodeRunTimeError
          next
        end
        return @qr unless @qr.nil?
      end
    else
      return @qr
    end
  end

  #states: :reserved, :downloadable, :issued, :canceled, :repaid
  state_machine initial: :reserved do
    event :purchase do
      transition :reserved => :downloadable, if: lambda {|sold_product| sold_product.order.paid?}
    end

    event :cancel do
      transition :reserved => :canceled, if: lambda {|sold_product| sold_product.order.canceled?}
    end

    event :use do
      transition :downloadable => :issued
    end

    event :repay do
      transition :downloadable => :repaid
    end

  end


  private
  #Creates a random ID in order to not know how much stuff is sold
  def randomize_id
    begin
      self.id = SecureRandom.random_number(1_000_000_000)
    end while SoldProduct.where(id: self.id).exists?
  end

end
