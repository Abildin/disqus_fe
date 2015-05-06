// Generated by CoffeeScript 1.9.1
'use strict';
var $this, HOST_NAME, module;

module = typeof exports !== "undefined" && exports !== null ? exports : this;

HOST_NAME = "http://localhost:8000";

$this = {
  getComments: function(url, offset, callback, errback) {
    return $.ajax({
      method: "GET",
      url: HOST_NAME + ("/api/v1/comment/?url__iexact=" + url + "&limit=3&offset=" + (offset * 3)),
      contentType: "application/json",
      dataType: "json",
      success: function(result) {
        return callback(result);
      },
      error: function(result) {
        return errback(result);
      }
    });
  },
  getCount: function(url, callback, errback) {
    return $.ajax({
      method: "GET",
      url: HOST_NAME + ("/api/v1/comment/?url__iexact=" + url + "&total_count=true"),
      contentType: "application/json",
      dataType: "json",
      success: function(result) {
        return callback(result);
      },
      error: function(result) {
        return errback(result);
      }
    });
  },
  newComment: function(url, title, email, text, replyTo, callback, errback) {
    return $.ajax({
      method: "POST",
      url: HOST_NAME + "/api/v1/comment/",
      contentType: "application/json",
      dataType: "json",
      data: JSON.stringify({
        url: url,
        title: title,
        email: email,
        text: text,
        replyTo: replyTo
      }),
      success: function(result) {
        return callback(result);
      },
      error: function(result) {
        return errback(result);
      }
    });
  }
};

module.Backend = $this;
