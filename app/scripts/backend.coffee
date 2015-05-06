'use strict';

module = exports ? this

HOST_NAME = "http://localhost:8000"

$this =
  # 
  # Helper method to get comments
  # url - url of queried site
  # offset - page in pagination // DEFAULT = 0
  # 
  # Comment number per page - 3
  # 
  getComments: (url, offset, callback, errback) ->
    $.ajax
      method: "GET"
      url: HOST_NAME + "/api/v1/comment/?url__iexact=#{url}&limit=3&offset=#{offset*3}"
      contentType: "application/json"
      dataType: "json"
      success: (result)->
        callback result
      error: (result)->
        errback result
  # 
  # Helper method to get comments number
  # 
  getCount: (url, callback, errback) ->
    $.ajax
      method: "GET"
      url: HOST_NAME + "/api/v1/comment/?url__iexact=#{url}&total_count=true"
      contentType: "application/json"
      dataType: "json"
      success: (result)->
        callback result
      error: (result)->
        errback result
  # 
  # Helper method to post new comments
  # url - url of queried site
  # title - name of user
  # email - email of user
  # text - text of comment
  # replyTo - uri to replied comment // DEFAULT = null
  # 
  newComment: (url, title, email, text, replyTo, callback, errback) ->
    $.ajax
      method: "POST"
      url: HOST_NAME + "/api/v1/comment/"
      contentType: "application/json"
      dataType: "json"
      data: JSON.stringify
        url: url
        title: title
        email: email
        text: text
        replyTo: replyTo
      success: (result)->
        callback result
      error: (result)->
        errback result

module.Backend = $this