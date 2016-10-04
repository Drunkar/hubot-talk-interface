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
btoir = require "hubot-btoir"

module.exports = (robot) ->
  unless config.roomId?
      robot.logger.error 'process.env.HUBOT_AISATSU_ROOM_ID is not defined'
      return
    unless config.people?
      robot.logger.error 'process.env.HUBOT_AISATSU_PEOPLE is not defined'
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

    if text == "電気消して"
      code = btoir.codes.light_off
      message = ""
      child_process.exec btoir.CODE_PREFIX + code, (err, stdout, stderr) ->
        if err
          message = "Error: Something was wrong!"
        else
          message = "Turn off the light."
        envelope = room: config.roomId
        robot.send envelope, message

  robot.router.get "/input", (req, res) ->
    fs.readFile path.join(__dirname, "hubot-talk-input.html"), (err, html) ->
      res.type "html"
      res.send html