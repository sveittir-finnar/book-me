import $ from "jquery";
import _ from "lodash";

function handleValidationErrors (changesets) {
  let errorListTag = $('#errors > ul').empty();
  $('.form-control').css('border', '');

  _.forEach(changesets, changeset => {
    let modelName = _.keys(changeset)[0];
    _.forEach(changeset, (keys, modelName) => {
      _.forEach(keys, (errors, key) => {
        // Make red
        let inputId = `#${modelName}_${key}`;
        let borderBefore = $(inputId).css('border');
        $(inputId).css('border', 'solid 1px red');

        // Add to errors list
        let prettyKey = _.capitalize(key.replace('_', ' '));
        let prettyError = _.capitalize(errors);
        errorListTag.append(`<li>${prettyKey}: ${prettyError}.</li>`);
      })
    });
  });
  $('#errors').show();
}

$(document).ready(() => {
  $('#registration_form').submit(function () {
    event.preventDefault();
    let form = $(this).serializeArray();
    // [{ name: 'a', value: 1 }, { name: 'b', value: 3 }] => {a: 1, b: 3}
    let body = _.zipObject(_.map(form, 'name'), _.map(form, 'value'));
    $.ajax({
      method: 'POST',
      url: '/registration',
      dataType: 'json',
      data: body
    })
    .done((data) => {
      console.log('data:', data);
    })
    .fail((err, status) => {
      // Validation error?
      if (err.status === 422) {
        handleValidationErrors(err.responseJSON);
      }
    });
  });
});
