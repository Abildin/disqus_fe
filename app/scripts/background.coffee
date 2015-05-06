'use strict';

# this script is used in background.html

# 
# Method for updating badge text for specific site
# 
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

# 
# Listener for handling tab activation
# 
chrome.tabs.onActivated.addListener (activeInfo) ->
  chrome.tabs.get activeInfo.tabId, (tab) ->
    if tab.url
      url = new URL(tab.url).hostname
      updateBadge url

# 
# Listener for handling alerms
# 
chrome.alarms.onAlarm.addListener (alarm) ->
  # 
  # Handle "update" alarm
  # 
  if alarm.name == "update"
    chrome.tabs.query
      currentWindow: true
      active: true
    , (tabs) ->
      tab = tabs[0]
      if tab.url
        url = new URL(tab.url).hostname
        updateBadge url

# 
# Listener for responding extension requests
# 
chrome.extension.onRequest.addListener (request, sender, sendResponse) ->
  # 
  # Handle "getUser" alarm
  # 
  # Return current user name and email from storage
  # 
  if request.command == "getUser"
    chrome.storage.sync.get 'disqus.user', (item) ->
      if item['disqus.user']
        user = JSON.parse(item['disqus.user'])
        sendResponse
          user: user
  # 
  # Handle "setUser" alarm
  # 
  # Save current user name and email in storage
  # 
  if request.command == "setUser"
    chrome.storage.sync.set 
      'disqus.user': JSON.stringify(request.user)
  if request.command == "newComment" || request.command == "getComments"
    chrome.tabs.query
      currentWindow: true
      active: true
    , (tabs) ->
      tab = tabs[0]
      if tab.url
        url = new URL(tab.url).hostname
        # 
        # Handle "getComments" alarm
        # 
        # User helper methed from Backend module to get comments list for url
        # 
        if request.command == "getComments"
          offset = request.offset || 0
          Backend.getComments url, offset, (response) ->
            sendResponse
              status: "success"
              response: response
          , (error) ->
            sendResponse
              status: "error"
              response: error
        # 
        # Handle "newComment" alarm
        # 
        # User helper methed from Backend module to save comment for url
        # 
        if request.command == "newComment"
          user = request.user
          comment = request.comment
          Backend.newComment url, user.title, user.email, comment.text, comment.replyTo, (response) ->
            sendResponse
              status: "success"
              response: response
            updateBadge url
          , (error) ->
            sendResponse
              status: "error"
              response: error

chrome.alarms.create("update", {periodInMinutes: 0.01})