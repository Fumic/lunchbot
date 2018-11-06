module.exports = (robot) ->
  BRAIN_KEY='notes'
  robot.respond /add\s+note\s+(.+)\s*$/, (res) ->
    userID=res.envelope.user.id
    text=res.match[1]
    notes=robot.brain.get(BRAIN_KEY)||{}
    myNotes=notes[userID] || []
    myNotes.push text
    notes[userID]=myNotes
    robot.brain.set BRAIN_KEY, notes
    robot.brain.save()
    res.reply "保存しました　id: `#{myNotes.length -　1}`"
    
  robot.respond /list\s+notes?\s*$/, (res) ->
    userID=res.envelope.user.id
    notes=robot.brain.get(BRAIN_KEY) || {}
    myNotes=notes[userID]
    res.reply '保存済みのメモ\n' + myNotes.map((note, i) -> "#{i}:#{note}").join('\n')
    
  robot.respond /remove\s+notes?\s+(\d)\s*$/, (res) ->
    userID=res.envelope.user.id
    index=parseInt res.match[1]
    notes=robot.brain.get(BRAIN_KEY) || {}
    myNotes=notes[userID] || []
    removed = myNotes.splice index, 1
    if removed.length == 0
      res.reply '該当する番号のメモはありません'
      return
    notes[userID]=myNotes
    robot.brain.set BRAIN_KEY, notes
    robot.brain.save()
    res.reply "削除しました: `#{removed[0]}`"
