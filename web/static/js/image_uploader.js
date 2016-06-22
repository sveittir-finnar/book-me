'use strict';
import $ from 'jquery';
import _ from 'lodash';

const input = $('#image-upload-input');
const form  = $('#image-upload-form');

form.submit(function (evt) {
  evt.preventDefault();
  let url = form.attr('action');

  $.post({
    url,
    data: new FormData(this),
    processData: false,
    contentType: false
  })
  .done((res) => {
    console.log(res);
    form.attr('data-url', `/${res.path}`);
  })
  .fail(console.error);

});

input.change(function () {
  let image = _.first(this.files);
  let imageElem = $('.image-uploader img');
  if (!image.type.match(/^image\//)) {
    //TODO(kthelgason): handle error
    return;
  }

  let reader = new FileReader();
  reader.onload = (evt) => {
    imageElem.attr('src', evt.target.result);
  };
  reader.readAsDataURL(image);
  form.submit();
});

// Forward clicks to the hidden input
$('.image-uploader').click((e) => {
  e.preventDefault();
  if (input) {
    input.click();
  } else {
    console.error('input element not found');
  }
});

function getUploadPath () {
  return form.attr('data-url');
}

export { getUploadPath };
