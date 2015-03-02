# encoding: utf-8
class SoldProductPdf < Prawn::Document
  #include Prawn::View

  def initialize(sold_product, event, validation_url)
    super( page_size: "A4")
    @sold_product = sold_product
    @event = event
    @validation_url = validation_url
    logo
    move_up 120
    heading
    date
    move_down 100
    product

    qr_code
    author
    kleinbetragsrechnung
  end

  def heading
    text "Online Ticket\n& Quittung \##{@sold_product.id}", style: :bold, size: 30, align: :right
  end

  def logo
    svg File.open("/Users/meye/Desktop/eh15v4-1.svg", "r"), :at => [-50, 780], :width => 250
  end

  def date
    text "#{I18n.l @sold_product.created_at.to_date}", align: :right
  end

  def qr_code
    move_down 300
    render_qr_code @sold_product.qr(@validation_url), :dot=>4
    text "Token: #{@sold_product.verification_token}"
  end

  def author
    text_box "#{@event.company_name}, #{@event.company_address}", style: :italic, size: 10, at: [0, 45]
  end

  def kleinbetragsrechnung
    text_box "Dieses Ticket gilt gleichzeitig als Kleinbetragsrechnung im Sinne vom §33 UStDV. Umtausch und Rückgabe ausgeschlossen.", style: :italic, size: 10, at: [0, 30]
  end

  def product
    text "#{@sold_product.name}", size: 20
    text " #{ActionController::Base.helpers.number_to_currency @sold_product.price} (inkl. #{ActionController::Base.helpers.number_to_currency @sold_product.tax_price} MwSt.)", size: 15

  end

end
