'use strict';
import $ from 'jquery';
import { getUploadPath } from './image_uploader';

const form = $('#employee-form');

form.submit(function (evt) {
  let newUrl = getUploadPath();
  if (newUrl) {
    $('#employee_avatar_url').val(newUrl);
  }

});
