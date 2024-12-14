class EmailsController < ApplicationController
  def index
    matching_emails = Email.all

    @list_of_emails = matching_emails.order({ :created_at => :desc })

    render({ :template => "emails/index" })
  end

  def yes_index
    matching_emails = Email.all.where({ :pitch_status => "Yes"})

    @list_of_emails = matching_emails.order({ :created_at => :desc })

    render({ :template => "emails/index" })
  end

  def no_index
    matching_emails = Email.all.where({ :pitch_status => "No"})

    @list_of_emails = matching_emails.order({ :created_at => :desc })

    render({ :template => "emails/index" })
  end

  def uncertain_index
    matching_emails = Email.all.where({ :pitch_status => "Uncertain"})

    @list_of_emails = matching_emails.order({ :created_at => :desc })

    render({ :template => "emails/index" })
  end

  def show
    the_id = params.fetch("path_id")

    matching_emails = Email.where({ :id => the_id })

    @the_email = matching_emails.at(0)

    render({ :template => "emails/show" })
  end

  def create
    the_email = Email.new
    the_email.user_id = current_user.id
    the_email.subject = params.fetch("query_subject")
    the_email.body = params.fetch("query_body")
    the_email.sender = params.fetch("query_sender")
    

    ask = "is there an specific event in chicago contained within the following text that is being advertised, such as a concert, play, or gallery exhibition which may be of interest for journalistic coverage? note that for all events, we require specific dates or a range of dates. if yes, return 'Yes', if uncertain, return 'Uncertain', if no, return 'No'. your response can only be one of these three words, nothing more or less." + params.fetch("query_body")

    ask2 = "Based on the above text, give me a pitch formatted as such: 'Event Name @ Location (Month/Date)', consult these following examples: New Hope Club @ Beat Kitchen (12/5), Tokyo Police Club @ House of Blues (12/7), Totally '80s HoliGAY @ Several Locations (12/6, 12/8, 12/12), Illiterate Light @ Schubas Tavern (12/7). This format is strict, do not include any extraneous information. Keep as concise as possible."

    client = OpenAI::Client.new(access_token: ENV.fetch("OPENAI_KEY"))

    messages = client.chat(
      parameters: {
        model: "gpt-3.5-turbo",
        messages: [
          { role: "system", content: "You help sort emails for the arts section of the Chicago Maroon, University of Chicago's newspaper " },
          { role: "user", content: ask }
        ],
        temperature: 0
      }
    )

    response = messages.fetch("choices").at(0).fetch("message").fetch("content").to_s

    the_email.pitch_status = response

    if the_email.pitch_status == "Yes"
      messages2 = client.chat(
        parameters: {
          model: "gpt-3.5-turbo",
          messages: [
            { role: "system", content: "You help sort emails for the arts section of the Chicago Maroon, University of Chicago's newspaper " },
            { role: "user", content: params.fetch("query_body") + ask2 }
          ],
          temperature: 0
        }
      )

      response2 = messages2.fetch("choices").at(0).fetch("message").fetch("content").to_s

      the_email.pitch = response2
    else
      the_email.pitch = ""
    end

    if the_email.valid?
      the_email.save
      if the_email.pitch_status == "Yes"
      redirect_to("/emails", { :notice => "This email seems to contain a pitch." })
      elsif the_email.pitch_status == "No"
      redirect_to("/emails", { :notice => "This email does not seem to contain a pitch." })
      else
      redirect_to("/emails", { :notice => "It is uncertain if this email contains a pitch. Please check manually." })
      end

    else
      redirect_to("/emails", { :alert => the_email.errors.full_messages.to_sentence })
    end
  end

  def update
    the_id = params.fetch("path_id")
    the_email = Email.where({ :id => the_id }).at(0)

    the_email.user_id = current_user.id
    the_email.subject = params.fetch("query_subject")
    the_email.body = params.fetch("query_body")
    the_email.sender = params.fetch("query_sender")
    the_email.pitch_status = params.fetch("query_pitch_status")
    the_email.pitch = params.fetch("query_pitch")

    if the_email.valid?
      the_email.save
      redirect_to("/emails/#{the_email.id}", { :notice => "Email updated successfully."} )
    else
      redirect_to("/emails/#{the_email.id}", { :alert => the_email.errors.full_messages.to_sentence })
    end
  end

  def destroy
    the_id = params.fetch("path_id")
    the_email = Email.where({ :id => the_id }).at(0)

    the_email.destroy

    redirect_to("/emails", { :notice => "Email deleted successfully."} )
  end
end
