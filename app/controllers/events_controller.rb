class EventsController < ApplicationController
  before_action :authenticate_user!, except:[:show, :index, :calendar]


  def index

    if params[:slack]
      @events = Event.booked_with(params[:slack]).this_week
    else
      @events = Event.this_week
    end

    respond_to do |format|
      format.html
      format.json  { render :json => custom_json_for(Event.all) }
      format.ics do
        cal = Icalendar::Calendar.new
        @events.each do |event|
          cal.add_event(event.to_ics)
          cal.publish
        end
        render :text => cal.to_ical
      end
    end

  end
  def destroy_all
    @events = Event.all.this_week
    @events.destroy_all
    redirect_to events_path
  end

  def ics_export

    @events = Event.all.this_week
    respond_to do |format|
      format.html
      format.ics do
        cal = Icalendar::Calendar.new
        @events.each do |event|
          cal.add_event(event.to_ics)
          cal.publish
        end
        render :text => cal.to_ical
      end
    end
  end


  def show
    @event = Event.find(params[:id])

    respond_to do |format|
      format.html
      format.ics do
        cal = Icalendar::Calendar.new
        cal.add_event(@event.to_ics)
        cal.publish
        render :text => cal.to_ical
      end
    end
  end


  def new
    @event = Event.new

  end

  def create
    @event = Event.new(event_parmas)
    if @event.save!
      redirect_to events_path
    else
      render :new
    end
  end

  def edit
    @event = Event.find(params[:id])
  end


  def update
    @event = Event.find(params[:id])
    if @event.update(event_parmas)
      redirect_to events_path
    else
      render :edit
    end
  end

  def destroy
    @event = Event.find(params[:id])
    @event.destroy
    redirect_to events_path
  end

  def import
    Event.import(params[:file])
    redirect_to root_url, notice: "Events imported."
  end

  private

  def event_parmas
    params.require(:event).permit(:start_time,:end_time,:summary, :content, :all_slacks,:week_table_id)
  end

  def custom_json_for(value)
    list = value.map do |event|
      {
        :allDay => "",
        :title => event.all_slacks.to_s,
        :id => " #{event.id}",
        :start => event.start_time.to_s,
        :end => event.end_time.to_s,
        :color => calendar_color(event)
      }
    end
    list.to_json
  end

  def calendar_color(event)
    case event.summary[0,4]
    when '10am'
      'green'
    end
  end

end
