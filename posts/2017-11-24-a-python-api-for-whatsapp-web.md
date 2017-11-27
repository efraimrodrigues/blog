---
title: A Python API for Whatsapp Web
author: Efraim Rodrigues
tags: python, whatsapp, javascript
---

[![Documentation Status](https://readthedocs.org/projects/whapy/badge/?version=latest)](http://whapy.readthedocs.io/en/latest/?badge=latest)

Available on <a href="http://github.com/efraimrodrigues/WhaPy" target="_blank">GitHub<img width="2%" src="/files/GitHub-Mark-64px.png"/></a>

## WhaPy: A Python API for Whatsapp Web

This article explains the basis of WhaPy a API for Whatsapp Web that allows chatbots to be created. Please refer to the [documentation](http://whapy.readthedocs.io/) for detailed information on how to use it.



### Intro
Whatsapp has been claimed to be one of the most used conversation application in the western world. It seems whatsapp has not made plans for implementing an API (Application Programming Interface) in a near future. An API would allow developers to implement chatbots to provide automated services on it. Although whatsapp doesn't seem willing to implement an API, whatsapp web seemed to make it possible for an unofficial API.

###  WhatsApp Web
Whatsapp Web is the whatsapp version for browsers, but it requires the mobile application to be online simultaneously. This version uses [ReacJs](https://reactjs.org/) which is a JavaScript library for building applications' interfaces.

[ReacJs](https://reactjs.org/) defines a virtual DOM in order to perform updates in the DOM more efficiently. [Here's](http://blog.reverberate.org/2014/02/react-demystified.html) an explanation of React's perks. Whatsapp Web's architecture defines React on top of the architecture to make requests to lower layers. Then, the frontend Store is defined to provided a interface for this.

### Frontend Store
The frontend Store defines a set of objects and functions to work with the architecture's lower layers. Here's a list of objects defined on the frontend Store:

- AllStarredMsgs
- Blocklist
- Call
- Chat
- ChatPreference
- Cmd
- Conn
- Contact
- ConversionTuple
- EmojiVariant
- GroupMetadata
- Location
- Msg
- MsgInfo
- Mute
- Presence
- ProfilePicThumb
- RecentEmoji
- ServerProps
- StarredGifMsgs
- Status
- StatusV3
- StatusV3Privacy
- Stream
- Wap

Most of these objects are comprehensible by their names, and their functions are self explanatory. List of objects are usually store in the <i>models</i> attribute. For instance, using JavaScript, <i>Store.Chat.models</i> gives access to the list of chats and  <i>Store.Chat.models[0].sendMessage("Hello!")</i> will send a message to the first chat. These objects could be seen as whatsapp classes' managing beans. <i>Store.Chat</i> is the most used object in WhaPy and it's used for listening to events, sending messages and managing chats.

### WhaPy
WhaPy provides two events. They are <i>on_message</i> and <i>on_ready</i>. <i>on_message</i> is fired each time a new message is detected and <i>on_ready</i> is fired when all chats are loaded in the frontend store. Besides these two events, WhaPy also offers interfaces for managing chats and messages. 

#### on_message
This event watches chats via JavaScript (this will be addressed in the next topics). Once the JavaScript code detects an unread message in a chat, the routine will invoke a method for handling unread messages.

#### on_ready
Because the whatsapp web page is not loaded completely at once, this event is fired each time the chats objects are present in the page.

For handling a whatsapp web session WhaPy uses the [selenium](http://selenium-python.readthedocs.io/) library for managing the page via JavaScript. Selenium allows WhaPy to open a web browser and control it with JavaScript code. Perhaps the most beautiful thing about selenium is that it allows objects to go from JavaScript to Python.
