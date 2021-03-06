class OrderMailer < ActionMailer::Base

  def reservation_confirmation(user, order)
    @user = user
    @order = order
    @event = order.event

    mail to: user.email, subject: t("order_mailer.event Presale Reservation#order_id", event: order.event.name, order_id: order.id)
  end

  def purchase_confirmation(user, order)
    @user = user
    @order = order
    @event = order.event

    mail to: user.email, subject: t("order_mailer.event Presale Payment confirmation#order_id", event: order.event.name, order_id: order.id)
  end

  def payment_reminder(user, open_orders, event)
    @user = user
    @open_orders = open_orders
    @event = event

    mail to: user.email, subject: t("order_mailer.event Presale Payment reminder", event: event.name)
  end

end
