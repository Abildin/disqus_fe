// Generated by CoffeeScript 1.9.1
'use strict';
var updateBadge;

updateBadge = function(url) {
  return Backend.getCount(url, function(result) {
    if (result.total_count > 0) {
      return chrome.browserAction.setBadgeText({
        text: result.total_count.toString()
      });
    } else {
      return chrome.browserAction.setBadgeText({
        text: ""
      });
    }
  }, function(error) {
    return chrome.browserAction.setBadgeText({
      text: "Error"
    });
  });
};

chrome.tabs.onActivated.addListener(function(activeInfo) {
  return chrome.tabs.get(activeInfo.tabId, function(tab) {
    var url;
    if (tab.url) {
      url = new URL(tab.url).hostname;
      return updateBadge(url);
    }
  });
});

chrome.alarms.onAlarm.addListener(function(alarm) {
  if (alarm.name === "update") {
    return chrome.tabs.query({
      currentWindow: true,
      active: true
    }, function(tabs) {
      var tab, url;
      tab = tabs[0];
      if (tab.url) {
        url = new URL(tab.url).hostname;
        return updateBadge(url);
      }
    });
  }
});

chrome.extension.onRequest.addListener(function(request, sender, sendResponse) {
  if (request.command === "newComment" || request.command === "getComments") {
    return chrome.tabs.query({
      currentWindow: true,
      active: true
    }, function(tabs) {
      var comment, tab, url, user;
      tab = tabs[0];
      if (tab.url) {
        url = new URL(tab.url).hostname;
        if (request.command === "getComments") {
          Backend.getComments(url, function(response) {
            return sendResponse({
              status: "success",
              response: response
            });
          }, function(error) {
            return sendResponse({
              status: "error",
              response: error
            });
          });
        }
        if (request.command === "newComment") {
          user = request.user;
          comment = request.comment;
          return Backend.newComment(url, user.title, user.email, comment.comment, comment.replyTo, function(response) {
            sendResponse({
              status: "success",
              response: response
            });
            return updateBadge(url);
          }, function(error) {
            return sendResponse({
              status: "error",
              response: error
            });
          });
        }
      }
    });
  }
});

chrome.alarms.create("update", {
  periodInMinutes: 0.01
});