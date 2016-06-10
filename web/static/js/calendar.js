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
  if (calendar.length === 0) {
    return;
  }

  populate(calendar);

  $('#reservation-form').submit(event => {
    console.log($('#reservation-form').serializeArray());
    event.preventDefault();
  });

  $('#reservation-client-id').select2();
  $('#reservation-employee-id').select2();

  // If all_day is checked, the start time should be disabled.
  $('#reservation-all-day').change(() => {
    let isChecked = $('#reservation-all-day').is(':checked');
    if (isChecked) {
      $('#reservation-start-time').attr('disabled', 'true');
    } else {
      $('#reservation-start-time').removeAttr('disabled');
    }
  });

  // Default the duration of the appointment to that of the service's
  $('#reservation-service-id').change(() => {
    let serviceId = $('#reservation-service-id').val();
    if (serviceId !== '') {
      let option = $(`#reservation-service-id > option[value="${serviceId}"]`);
      let duration = option.data('duration');
      let hours = Math.floor(duration / 60);
      let minutes = duration % 60;
      $('#reservation-duration-hours').val(hours);
      $('#reservation-duration-minutes').val(minutes);
      $('#service-details').show();
    } else {
      $('#service-details').hide();
    }
  });
});
