// Generated by CoffeeScript 1.9.1
'use strict';
var CommentRactive, r;

CommentRactive = Ractive.extend({
  template: '#comments-t',
  data: {
    user: {
      title: null,
      email: null
    },
    comment: {
      replyTo: null,
      text: null
    },
    comments: [],
    formatFull: function(time) {
      var timestamp;
      timestamp = new Date(time);
      return (this.formatDate(timestamp)) + " " + (this.formatTime(timestamp));
    },
    format: function(time) {
      var now, timestamp;
      timestamp = new Date(time);
      now = new Date();
      if (this.formatDate(timestamp) === this.formatDate(now)) {
        return this.formatTime(timestamp);
      } else {
        return this.formatDate(timestamp);
      }
    },
    md5: function(text) {
      return md5(text);
    }
  },
  formatTime: function(date) {
    var result;
    result = "";
    if (date.getHours().toString().length < 2) {
      result += "0";
    }
    result += date.getHours() + ":";
    if (date.getMinutes().toString().length < 2) {
      result += "0";
    }
    result += date.getMinutes() + ":";
    if (date.getSeconds().toString().length < 2) {
      result += "0";
    }
    result += date.getSeconds();
    return result;
  },
  formatDate: function(date) {
    var result;
    result = (date.getFullYear()) + "-";
    if ((date.getMonth() + 1).toString().length < 2) {
      result += "0";
    }
    result += (date.getMonth() + 1) + "-";
    if (date.getDate().toString().length < 2) {
      result += "0";
    }
    result += date.getDate();
    return result;
  },
  query: function(event) {
    this.getList(this.get('q'));
    return false;
  },
  next: function() {
    var meta, offset;
    meta = this.get('meta');
    if (meta.next) {
      offset = Math.floor(meta.offset / meta.limit) + 1;
      return this.getComments(offset);
    }
  },
  prev: function() {
    var meta, offset;
    meta = this.get('meta');
    if (meta.previous) {
      offset = Math.floor(meta.offset / meta.limit) - 1;
      return this.getComments(offset);
    }
  },
  getComments: function(offset) {
    var self;
    if (offset == null) {
      offset = 0;
    }
    self = this;
    return chrome.extension.sendRequest({
      command: "getComments",
      offset: offset
    }, function(response) {
      if (response.status === 'success') {
        self.set('meta', response.response.meta);
        self.set('comments', response.response.objects);
        console.log(response.response.meta);
        return console.log(response.response.objects);
      }
    });
  },
  replyTo: function(comment) {
    this.set('comment.replyTo', comment.resource_uri);
    return this.set('comment.text', comment.title + ", ");
  },
  newComment: function() {
    var comment, self, user;
    self = this;
    user = this.get('user');
    comment = this.get('comment');
    if (user.title && user.email) {
      return chrome.extension.sendRequest({
        command: "newComment",
        user: user,
        comment: {
          text: comment.text,
          replyTo: comment.replyTo
        }
      }, function(response) {
        console.log(response);
        if (response.status === 'success') {
          self.set('comment', null);
          return self.getComments();
        }
      });
    } else {
      self = this;
      this.set('error', 'Fill name/email fields');
      return setTimeout(function() {
        return self.set('error', null);
      }, 2000);
    }
  },
  save: function() {
    var user;
    user = this.get('user');
    return chrome.extension.sendRequest({
      command: "setUser",
      user: user
    });
  },
  init: function(options) {
    var self;
    self = this;
    chrome.extension.sendRequest({
      command: "getUser"
    }, function(response) {
      return self.set('user', response.user);
    });
    return this.getComments();
  }
});

r = new CommentRactive({
  el: '#comments-r'
});
