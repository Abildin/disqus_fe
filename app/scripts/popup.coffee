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
      text: null
    comments: []
    formatFull: (time) ->
      timestamp = new Date(time)
      return "#{this.formatDate(timestamp)} #{this.formatTime(timestamp)}"
    format: (time) ->
      timestamp = new Date(time)
      now = new Date()
      if this.formatDate(timestamp) == this.formatDate(now)
        return this.formatTime(timestamp)
      else
        return this.formatDate(timestamp)
    md5: (text) ->
      return md5(text)
  formatTime: (date) ->
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
  formatDate: (date) ->
    result = "#{date.getFullYear()}-"
    if (date.getMonth() + 1).toString().length < 2
      result += "0"
    result += (date.getMonth() + 1) + "-"
    if date.getDate().toString().length < 2
      result += "0"
    result += date.getDate()
    return result
  query: (event) ->
    this.getList(this.get('q'))
    return false
  next: () ->
    meta = this.get 'meta'
    if meta.next
      offset = Math.floor(meta.offset / meta.limit) + 1
      this.getComments(offset)
  prev: () ->
    meta = this.get 'meta'
    if meta.previous
      offset = Math.floor(meta.offset / meta.limit) - 1
      this.getComments(offset)
  getComments: (offset=0) ->
    self = this
    chrome.extension.sendRequest 
      command: "getComments"
      offset: offset
    , (response) ->
      if response.status == 'success'
        self.set 'meta', response.response.meta
        self.set 'comments', response.response.objects
        console.log response.response.meta
        console.log response.response.objects
  replyTo: (comment) ->
    this.set 'comment.replyTo', comment.resource_uri
    this.set 'comment.text', "#{comment.title}, "
  newComment: () ->
    self = this
    user = this.get 'user'
    comment = this.get 'comment'
    if user.title && user.email
      chrome.extension.sendRequest
        command: "newComment"
        user: user
        comment: 
          text: comment.text
          replyTo: comment.replyTo
      , (response) ->
        console.log response
        if response.status == 'success'
          self.set 'comment', null
          self.getComments()
    else
      self = this
      this.set 'error', 'Fill name/email fields'
      setTimeout () ->
        self.set 'error', null
      , 2000
  save: () ->
    user = this.get 'user'
    chrome.extension.sendRequest
      command: "setUser"
      user: user
  init: (options) ->
    self = this
    chrome.extension.sendRequest
      command: "getUser"
    , (response) ->
      self.set 'user', response.user
    this.getComments()

r = new CommentRactive 
  el: '#comments-r'