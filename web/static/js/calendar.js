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
  $('#errors').hide();
}

function showError(elem, message) {
  elem.html(`<span style="color: red">${message}</span>`);
  elem.show();
  return 1;
}

function validate(form) {
  let errors = 0;

  // Date & time
  let startDate = $('#start-date');
  if (!isDate(startDate.val())) {
    errors += showError($('#start-date-err'), 'You must pick a date!');
  }
  let allDay = $('#all-day');
  let startTime = $('#start-time');
  if (!allDay.is(':checked') && !isTime(startTime.val())) {
    errors += showError($('#start-time-err'),
      'You must either pick a time OR an all day event!');
  }

  let type = $('#type').val();
  if (type === 'client') {
    // Validations specific to client reservations
    // Client ID
    let clientId = $('#client-id');
    if (!isUuid(clientId.val())) {
      errors += showError($('#client-id-err'), 'You must choose a client!');
    }

    // Service ID
    let serviceId = $('#service-id').val();
    if (!isUuid(serviceId) && serviceId !== 'other') {
      errors += showError($('#service-id-err'),
        'You must either choose a service or "other" and fill in the details.');
    }
  } else if (type === 'personal') {
    // Validations specific to personal reservations
    let employeeId = $('#employee-id').val();
    if (!isUuid(employeeId)) {
      errors += showError($('#employee-id-err'), 'You must select the employee.');
    }

    // End time
    let endTime = $('#end-time');
    if (!allDay.is(':checked') && !isTime(endTime.val())) {
      errors += showError($('#end-time-err'),
        'You must either omit the end date, pick a time OR an all day event!');
    }
  }
  console.log('errors:', errors);
  return errors === 0;
}

function parseDateTime(data, dateKey, timeKey) {
  if (!isDate(data[dateKey])) {
    return null;
  }

  let time;
  if (data.all_day) {
    time = `${data[dateKey]} 00:00:00`;
  } else {
    if (!isTime(data[timeKey])) {
      return null;
    }
    time = `${data[dateKey]} ${data[timeKey]}:00`;
  }
  return time;
}

// TODO: Use immutable data structures, this sucks
function formToReservation(form) {
  let out;
  if (form.type === 'personal') {
    out = parsePersonalForm(form);
  } else {
    out = parseClientForm(form);
  }

  // all_day = 'on' -> all_day = true   <or>   all_day = false
  out.all_day = (out.all_day === 'on');

  // {start_date, start_time} -> start_time
  out.start_time = parseDateTime(out, 'start_date', 'start_time');
  delete out.start_date;

  // {end_date, end_time} -> end_time
  let endTime = parseDateTime(out, 'end_date', 'end_time');
  if (endTime) {
    out.end_time = endTime;
  } else {
    delete out.end_time;
  }
  delete out.end_date;

  // Update the keys to be on the form 'reservation[key]'.
  _.forEach(out, (value, key) => {
    out[`reservation[${key}]`] = value;
    delete out[key];
  });

  return out;
}

function parsePersonalForm(form) {
  return _.pick(form, [
    'type', 'title', 'all_day', 'employee_id', 'notes',
    'start_date', 'start_time', 'end_date', 'end_time'
  ]);;
}

function handleClient(form) {
  form = _.pick(form, [
    'type', 'all_day', 'employee_id', 'notes', 'start_date', 'start_time',
    'client_id', 'service_id', 'duration_hours', 'duration_minutes'
  ]);

  // duration_{hours, minutes} -> duration
  let hours = Number(form.duration_hours);
  let minutes = Number(form.duration_minutes);
  form.duration = hours * 60 + minutes;
  delete form.duration_hours;
  delete form.duration_minutes;

  return form;
}


$(() => {
  let calendar = $('#calendar');
  if (calendar.length === 0) {
    return;
  }

  populate(calendar);

  $('#reservation-submit').click(() => {
    $('#reservation-form').submit();
  })

  $('#reservation-form').submit(event => {
    // Start by validating the form
    clearErrors();
    let isValid = validate();
    if (!isValid) {
      event.preventDefault();
      return;
    }

    // Serialize it to a "reservation" object
    let arr = $('#reservation-form').serializeArray();
    // [{ name: 'a', value: 1 }, { name: 'b', value: 3 }] => {a: 1, b: 3}
    let form = _.zipObject(_.map(arr, 'name'), _.map(arr, 'value'));
    let body = formToReservation(form);
    $.ajax({
      method: 'POST',
      url: '/reservations',
      dataType: 'json',
      data: body,
      headers: {
        authorization: 'Bearer ' + document.access_token
      }
    })
    .done(data => {
      // TODO(krummi): modal.close() and refresh the calendar.
      alert('created!');
    })
    .fail((err, status) => {
      $('#errors').html(`<p>Unable to save your appointment, please contact support if problem persists (err: ${err.status} ${err.statusText}).</p>`);
      $('#errors').show();
    });

    event.preventDefault();
  });

  $('#client-id').select2();
  $('#employee-id').select2();

  $('#personal-btn').click(() => {
    $('#type').val('personal');

    $('#client').hide();
    $('#service').hide();
    $('#title').show();
    $('#end-time-container').show();

    clearErrors();

    $('#employee-id > option[value=""]').text('Select an employee');
  });

  $('#client-btn').click(() => {
    $('#type').val('client');

    $('#client').show();
    $('#service').show();
    $('#title').hide();
    $('#end-time-container').hide();

    clearErrors();

    $('#employee-id > option[value=""]').text('Any employee');
  });

  // If all_day is checked, the start time should be disabled.
  $('#all-day').change(() => {
    let isChecked = $('#all-day').is(':checked');
    if (isChecked) {
      $('#start-time').val('');
      $('#start-time').attr('disabled', 'true');
      $('#end-time').val('');
      $('#end-time').attr('disabled', 'true');
    } else {
      $('#start-time').removeAttr('disabled');
      $('#end-time').removeAttr('disabled');
    }
  });

  // Default the duration of the appointment to that of the service's
  $('#service-id').change(() => {
    let serviceId = $('#service-id').val();
    if (serviceId !== '') {
      let option = $(`#service-id > option[value="${serviceId}"]`);
      let duration = option.data('duration');
      let hours = Math.floor(duration / 60);
      let minutes = duration % 60;
      $('#duration-hours').val(hours);
      $('#duration-minutes').val(minutes);
      $('#service-details').show();
    } else {
      $('#service-details').hide();
    }
  });

  $('#client-btn').trigger('click');
});
