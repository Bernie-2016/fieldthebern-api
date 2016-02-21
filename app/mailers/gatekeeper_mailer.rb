class GatekeeperMailer < ApplicationMailer
  def pre_transfer(user)
    mail(
      to: user.email,
      subject: "Coming soon: New user login system for Field the Bern"
    )
  end
end
