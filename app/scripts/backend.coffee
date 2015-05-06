'use strict';

module = exports ? this

HOST_NAME = "http://localhost:8000"

$this =
  getComments: (url, callback, errback) ->
    $.ajax
      method: "GET"
      url: HOST_NAME + "/api/v1/comment/?url__iexact=#{url}"
      contentType: "application/json"
      dataType: "json"
      success: (result)->
        callback result
      error: (result)->
        errback result
  getCount: (url, callback, errback) ->
    $.ajax
      method: "GET"
      url: HOST_NAME + "/api/v1/comment/?url__iexact=#{url}&limit=0&total_count=true"
      contentType: "application/json"
      dataType: "json"
      success: (result)->
        callback result
      error: (result)->
        errback result
  newComment: (url, title, email, comment, replyTo, callback, errback) ->
    $.ajax
      method: "POST"
      url: HOST_NAME + "/api/v1/comment/"
      contentType: "application/json"
      dataType: "json"
      data: JSON.stringify
        url: url
        title: title
        email: email
        comment: comment
        replyTo: replyTo
      success: (result)->
        callback result
      error: (result)->
        errback result

module.Backend = $this