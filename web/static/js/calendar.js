import fullcalendar from 'fullcalendar'
import $ from 'jquery'

function toFullCalendarEvent (reservation) {
  let title = reservation.title;
  let start = reservation.start_time;
  let end   = reservation.computed.end_time;

  // Special handling for all_day == true
  if (reservation.all_day) {
    start = reservation.start_time.split('T')[0];
  }

  let res = { title, start };
  if (end) {
    res.end = end;
  }
  return res;
}

function populate (calendar) {
  $.ajax({
    url: '/reservations/',
    method: 'GET',
    headers: {
      authorization: 'Bearer ' + document.access_token
    }
  })
  .then(body => {
    let fullCalendarEvents = _.map(body.data, toFullCalendarEvent);
    calendar.fullCalendar({
      header: {
        left: 'prev,next today',
        center: 'title',
        right: 'month,agendaWeek,agendaDay'
      },
      defaultView: 'agendaWeek',
      editable: true,
      events: fullCalendarEvents
    });
  });
}


$(() => {
  let calendar = $('#calendar');
  if (calendar.length > 0) {
    populate(calendar);

    // Populate clients
    $("#client-id").select2();
  }
});
