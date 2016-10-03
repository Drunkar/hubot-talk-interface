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
Sound = require "node-aplay"
fs = require "fs"
path = require "path"

module.exports = (robot) ->
  voice = new VoiceText process.env.HUBOT_TALK_INTERFACE_API_KEY

  robot.router.get "/control", (req, res) ->
    text = if req.query.text then req.query.text else ""

    if text == "よつぎちゃん"
      text = "なんや"

    speaker       = if req.query.speaker then req.query.speaker else voice.SPEAKER.HARUKA
    emotion       = if req.query.emotion then req.query.emotion else voice.EMOTION.HAPPINESS
    emotion_level = if req.query.emotion_level then req.query.emotion_level else voice.EMOTION_LEVEL.LOW
    pitch         = if req.query.pitch then req.query.pitch else 100
    speed         = if req.query.speed then req.query.speed else 100
    volume        = if req.query.volume then req.query.volume else 100

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
      new Sound "talk.wav" .play

    res.send text

  robot.router.get "/input", (req, res) ->
    fs.readFile path.join(__dirname, "hubot-talk-input.html"), (err, html) ->
      res.type "html"
      res.send html