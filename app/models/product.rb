class Product < ActiveRecord::Base
  has_paper_trail
  belongs_to :event
  has_many :images, as: :imageable, dependent: :destroy
  has_many :sold_products

  def reserved_but_not_paid
    self.sold_products.with_state(:reserved)
  end

  def paid_or_issued
    self.sold_products.with_state(:downloadable,:issued)
  end

  def issued
    self.sold_products.with_state(:issued)
  end

  def available_count
    self.quantity - self.sold_products.length + self.sold_products.with_state(:canceled).length
  end

  def low_stock_warning
    if (self.available_count.to_f / self.quantity) <= 0.15
      return self.available_count
    end
    return false
  end
end
