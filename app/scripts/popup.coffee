'use strict';

# this script is used in popup.html

CommentRactive = Ractive.extend
  template: '#comments-t'
  data:
    user:
      title: null
      email: null
    comment:
      replyTo: null
      comment: null
    comments: []
    format: (time)->
      formatTime = (date)->
        result = ""
        if date.getHours().toString().length < 2
          result += "0"
        result += date.getHours() + ":"
        if date.getMinutes().toString().length < 2
          result += "0"
        result += date.getMinutes() + ":"
        if date.getSeconds().toString().length < 2
          result += "0"
        result += date.getSeconds()
        return result
      formatDate = (date)->
        result = "#{date.getFullYear()}-"
        if (date.getMonth() + 1).toString().length < 2
          result += "0"
        result += (date.getMonth() + 1) + "-"
        if date.getDate().toString().length < 2
          result += "0"
        result += date.getDate()
        return result
      timestamp = new Date(time)
      now = new Date()
      if formatDate(timestamp) == formatDate(now)
        return formatTime(timestamp)
      else
        return formatDate(timestamp)
  getComments: ()->
    self = this
    chrome.extension.sendRequest 
      command: "getComments"
    , (response) ->
      if response.status == 'success'
        self.set 'comments', response.response.objects
  replyTo: (comment)->
    this.set 'comment.replyTo', comment.resource_uri
    this.set 'comment.comment', "#{comment.title}, "
  newComment: ()->
    self = this
    user = this.get 'user'
    comment = this.get 'comment'
    chrome.extension.sendRequest
      command: "newComment"
      user: user
      comment: 
        comment: comment.comment
        replyTo: comment.replyTo
    , (response) ->
      console.log response
      if response.status == 'success'
        self.getComments()
  init: (options) ->
    this.getComments()

r = new CommentRactive 
  el: '#comments-r'