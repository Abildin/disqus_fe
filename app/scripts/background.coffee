'use strict';

# this script is used in background.html

updateBadge = (url) ->
  Backend.getCount url, (result) ->
    if result.total_count > 0
      chrome.browserAction.setBadgeText
        text: result.total_count.toString()
    else
      chrome.browserAction.setBadgeText
        text: ""
  , (error) ->
    chrome.browserAction.setBadgeText
      text: "Error"

chrome.tabs.onActivated.addListener (activeInfo) ->
  chrome.tabs.get activeInfo.tabId, (tab) ->
    if tab.url
      url = new URL(tab.url).hostname
      updateBadge url

chrome.alarms.onAlarm.addListener (alarm) ->
  if alarm.name == "update"
    chrome.tabs.query
      currentWindow: true
      active: true
    , (tabs) ->
      tab = tabs[0]
      if tab.url
        url = new URL(tab.url).hostname
        updateBadge url

chrome.extension.onRequest.addListener (request, sender, sendResponse) ->
  if request.command == "newComment" || request.command == "getComments"
    chrome.tabs.query
      currentWindow: true
      active: true
    , (tabs) ->
      tab = tabs[0]
      if tab.url
        url = new URL(tab.url).hostname
        if request.command == "getComments"
          Backend.getComments url, (response) ->
            sendResponse
              status: "success"
              response: response
          , (error) ->
            sendResponse
              status: "error"
              response: error
        if request.command == "newComment"
          user = request.user
          comment = request.comment
          Backend.newComment url, user.title, user.email, comment.comment, comment.replyTo, (response) ->
            sendResponse
              status: "success"
              response: response
            updateBadge url
          , (error) ->
            sendResponse
              status: "error"
              response: error

chrome.alarms.create("update", {periodInMinutes: 0.01})