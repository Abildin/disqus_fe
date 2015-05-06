'use strict';

# this script is used in popup.html

CommentRactive = Ractive.extend
  template: '#comments-t'
  data:
    # 
    # User's name and email
    # 
    # Required for posting comment
    # 
    user:
      title: null
      email: null
    # 
    # Comment's text and uri for repling to comment
    # 
    # text - Comment text
    # replyTo - uri of comment (OPTIONAL)
    # 
    comment:
      replyTo: null
      text: null
    # 
    # Comment's list for site
    # 
    comments: []
    # 
    # Helper method for formating comment's timespamp
    # 
    # Format "YYYY-MM-DD HH:mm:SS"
    # 
    formatFull: (time) ->
      timestamp = new Date(time)
      return "#{this.formatDate(timestamp)} #{this.formatTime(timestamp)}"
    # 
    # Helper method for formating comment's timespamp deppending on timestamp's date
    # 
    # If today's date
    # Format "HH:mm:SS"
    # 
    # If previous dates
    # Format "YYYY-MM-DD"
    # 
    format: (time) ->
      timestamp = new Date(time)
      now = new Date()
      if this.formatDate(timestamp) == this.formatDate(now)
        return this.formatTime(timestamp)
      else
        return this.formatDate(timestamp)
    # 
    # Helper method for creating md5 hash of user's email
    # 
    md5: (text) ->
      return md5(text)
  # 
  # Helper method for formating datetime to time
  # 
  # Format "HH:mm:SS"
  # 
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
  # 
  # Helper method for formating datetime to date
  # 
  # Format "YYYY-MM-DD"
  # 
  formatDate: (date) ->
    result = "#{date.getFullYear()}-"
    if (date.getMonth() + 1).toString().length < 2
      result += "0"
    result += (date.getMonth() + 1) + "-"
    if date.getDate().toString().length < 2
      result += "0"
    result += date.getDate()
    return result
  # 
  # Method for requesting next page of comments
  # 
  next: () ->
    meta = this.get 'meta'
    if meta.next
      offset = Math.floor(meta.offset / meta.limit) + 1
      this.getComments(offset)
  # 
  # Method for requesting previous page of comments
  # 
  prev: () ->
    meta = this.get 'meta'
    if meta.previous
      offset = Math.floor(meta.offset / meta.limit) - 1
      this.getComments(offset)
  # 
  # Method for requesting comments from background script
  # 
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
  # 
  # Method for repling to comments
  # 
  # Add "replyTo" to current comment and add prefix with username of replied comment's owner to comment text
  # 
  replyTo: (comment) ->
    this.set 'comment.replyTo', comment
    this.set 'comment.text', "#{comment.title}, #{this.get 'comment.text'}"
  # 
  # Method for canceling reply to comments
  # 
  # Remove "replyTo" from current comment and remove prefix from text if exist
  # 
  cancel: () ->
    repliedMessage = this.get 'comment.replyTo'
    newText = this.get 'comment.text'
    if newText.substring(0, repliedMessage.title.length + 2) == "#{repliedMessage.title}, "
      newText = newText.substring(repliedMessage.title.length + 2, newText.length)
    this.set 'comment.text', newText
    this.set 'comment.replyTo', null
  # 
  # Method for posting comment to server
  # 
  # Sends request to background script
  # 
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
  # 
  # Method that calls when username or email of user
  # 
  # Sends request to background for saving the user information
  # 
  save: () ->
    user = this.get 'user'
    chrome.extension.sendRequest
      command: "setUser"
      user: user
  # 
  # Initialization method
  # 
  # Gets user info from storage and requests comments list for current site
  # 
  init: (options) ->
    self = this
    chrome.extension.sendRequest
      command: "getUser"
    , (response) ->
      self.set 'user', response.user
    this.getComments()

# 
# Ractive for comments management
# 
r = new CommentRactive 
  el: '#comments-r'