import $ from "jquery";
import _ from "lodash";

function handleValidationErrors (changesets) {
  let errorListTag = $('#errors > ul').empty();

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
        setTimeout(() => {
          $(inputId).css('border', '');
        }, 3000);
      })
    });
  });

  $('#errors').show();
}

$(document).ready(() => {
  $('#registration_form').submit(function () {
    event.preventDefault();
    let form = $(this).serializeArray();
    // TODO(krummi): Use lodash for this
    let body = {};
    form.forEach(item => {
      body[item.name] = item.value;
    });
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
