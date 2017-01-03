#   Talk interface for hubot by speech recognition and speech synthesis.
#
# Dependencies:
#   voicetext
#   node-aplay
#   fs
#
# Configuration:
#   HUBOT_SPEECH_INTERFACE_API_KEY: voicetext api key.
#
# Commands:
#   None
#
# Author:
#   Drunkar <drunkars.p@gmail.com>
#

VoiceText = require "voicetext"
exec = require("child_process").exec
fs = require "fs"
path = require "path"
CODE_PREFIX = process.env.HUBOT_BTOIR_CODE_PREFIX
codes = require "hubot-btoir/src/ir_codes.json"

config =
  roomId: process.env.HUBOT_TALK_INTERFACE_ROOM_ID

module.exports = (robot) ->
  unless config.roomId?
      robot.logger.error "process.env.HUBOT_TALK_INTERFACE_ROOM_ID is not defined"
      return

  voice = new VoiceText process.env.HUBOT_TALK_INTERFACE_API_KEY

  robot.router.get "/control", (req, res) ->
    text = if req.query.text then req.query.text else ""

    if text == "よつぎちゃん"
      text = "なんや"

    speaker       = if req.query.speaker then req.query.speaker else voice.SPEAKER.HIKARI
    emotion       = if req.query.emotion then req.query.emotion else voice.EMOTION.SADNESS
    emotion_level = if req.query.emotion_level then req.query.emotion_level else 4
    pitch         = if req.query.pitch then req.query.pitch else 98
    speed         = if req.query.speed then req.query.speed else 100
    volume        = if req.query.volume then req.query.volume else 100
    aplay_hw      = if process.env.HUBOT_TALK_INTERFACE_HARDWARE then process.env.HUBOT_TALK_INTERFACE_HARDWARE else "0"

    voice.speaker speaker
    voice.emotion emotion
    voice.emotion_level emotion_level
    voice.pitch pitch
    voice.speed speed
    voice.volume volume
    voice.speak text, (e, buf) ->
      return fs.writeFile "./talk.wav", buf, "binary", (e) ->
        if e
          return console.error e
        # play mono audio
        exec "aplay -D plughw:" + aplay_hw + " ./talk.wav"

    res.send text

    if text == "エアコンとめて" or text == "エアコン止めて" or text == "エアコン消して"
      code = codes.aircon_off
      message = ""
      exec CODE_PREFIX + code, (err, stdout, stderr) ->
        if err
          message = "Error: Something was wrong!"
        else
          message = "Stop air-conditioning."
        envelope = room: config.roomId
        robot.send envelope, message

    else if text == "エアコンつけて"
      code = codes.aircon_on
      message = ""
      exec CODE_PREFIX + code, (err, stdout, stderr) ->
        if err
          message = "Error: Something was wrong!"
        else
          message = "Start air-conditioning."
        envelope = room: config.roomId
        robot.send envelope, message

    else if text == "電気消して" or text == "おやすみ" or text == "おやすみなさい" or text == "行ってきます" or text == "できます" or text == "いってきまーす" or text == "行きます" or text == "モス"
      code = codes.light_off
      message = ""
      exec CODE_PREFIX + code, (err, stdout, stderr) ->
        if err
          message = "Error: Something was wrong!"
        else
          message = "Turn off the light."
        envelope = room: config.roomId
        robot.send envelope, message

    else if text == "電気つけて" or text == "ただいま" or text == "タイマー" or text == "ドラマ" or text == "ドラえもん" or text == "buyma" or text == "長芋" or text == "ドm"
      code = codes.light_on
      message = ""
      exec CODE_PREFIX + code, (err, stdout, stderr) ->
        if err
          message = "Error: Something was wrong!"
        else
          message = "Turn on the light."
        envelope = room: config.roomId
        robot.send envelope, message

    else if text == "電気暗め" or text == "人気暗め" or text == "電気久留米" or text == "暗くして"
      code = codes.light_night
      message = ""
      exec CODE_PREFIX + code, (err, stdout, stderr) ->
        if err
          message = "Error: Something was wrong!"
        else
          message = "Turn the light to night mode."
        envelope = room: config.roomId
        robot.send envelope, message

    else if text == "テレビつけて" or text == "テレビ消して"
      code = codes.tv_power
      message = ""
      exec CODE_PREFIX + code, (err, stdout, stderr) ->
        if err
          message = "Error: Something was wrong!"
        else
          message = "Power tv."
        envelope = room: config.roomId
        robot.send envelope, message


  robot.router.get "/input", (req, res) ->
    fs.readFile path.join(__dirname, "hubot-talk-input.html"), (err, html) ->
      res.type "html"
      res.send html
