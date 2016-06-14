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

function isUuid(value) {
  return /^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i.test(value);
}

function isDate(value) {
  return /^\d{4}-\d{2}-\d{2}$/i.test(value);
}

function isTime(value) {
  return /^\d{2}:\d{2}$/i.test(value);
}

function clearErrors() {
  $('.errors').hide();
}

function showError(elem, message) {
  elem.html(`<span style="color: red">${message}</span>`);
  elem.show();
}

function validate(form) {
  // Date & time
  let startDate = $('#reservation-start-date');
  if (!isDate(startDate.val())) {
    showError($('#reservation-start-date-err'), 'You must pick a date!');
  }
  let allDay = $('#reservation-all-day');
  let startTime = $('#reservation-start-time');
  if (!allDay.is(':checked') && !isTime(startTime.val())) {
    showError($('#reservation-start-time-err'),
      'You must either pick a time OR an all day event!');
  }

  let type = $('#reservation-type').val();
  if (type === 'client') {
    // Validations specific to client reservations
    // Client ID
    let clientId = $('#reservation-client-id');
    if (!isUuid(clientId.val())) {
      showError($('#reservation-client-id-err'), 'You must choose a client!');
    }

    // Service ID
    let serviceId = $('#reservation-service-id');
    if (!isUuid(serviceId) && serviceId !== 'other') {
      showError($('#reservation-service-id-err'),
        'You must either choose a service or "other" and fill in the details.');
    }
  } else if (type === 'personal') {
    // Validations specific to personal reservations
    let employeeId = $('#reservation-employee-id').val();
    if (!isUuid(employeeId)) {
      showError($('#reservation-employee-id-err'),
        'You must select the employee.');
    }
  }
}

function formToReservation(form) {

}


$(() => {
  let calendar = $('#calendar');
  if (calendar.length === 0) {
    return;
  }

  populate(calendar);

  $('#reservation-form').submit(event => {
    // Start by validating the form
    clearErrors();
    validate();

    // Serialize it to a "reservation" object
    let arr = $('#reservation-form').serializeArray();
    // [{ name: 'a', value: 1 }, { name: 'b', value: 3 }] => {a: 1, b: 3}
    let form = _.zipObject(_.map(arr, 'name'), _.map(arr, 'value'));
    console.log(form);

    event.preventDefault();
  });

  $('#reservation-client-id').select2();
  $('#reservation-employee-id').select2();

  $('#personal-btn').click(() => {
    $('#reservation-type').val('personal');

    $('#client').hide();
    $('#service').hide();
    $('#title').show();

    clearErrors();

    $('#reservation-employee-id > option[value=""]').text('Select an employee');
  });

  $('#client-btn').click(() => {
    $('#reservation-type').val('client');

    $('#client').show();
    $('#service').show();
    $('#title').hide();

    clearErrors();

    $('#reservation-employee-id > option[value=""]').text('Any employee');
  });

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

  $('#client-btn').trigger('click');
});
