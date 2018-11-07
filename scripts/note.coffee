module.exports = (robot) ->
  BRAIN_KEY='notes'
  
  robot.respond /add\s+note\s+*\s+*$/, (res) ->
    #userID=res.envelope.user.id
    #text=res.match[1]
    category=res.match[1]
    text=res.match[2]
    notes=robot.brain.get(BRAIN_KEY)||{}
    myNotes=notes[category] || []
    myNotes.push text
    notes[category]=myNotes
    robot.brain.set BRAIN_KEY, notes
    robot.brain.save()
    res.reply "保存しました　id: `#{category}:#{myNotes.length -　1}`"
    
  robot.respond /list\s+notes?\s+*$/, (res) ->
    #userID=res.envelope.user.id
    category=res.match[1]
    notes=robot.brain.get(BRAIN_KEY) || {}
    myNotes=notes[category]
    res.reply '保存済みのメモ\n' + myNotes.map((note, i) -> "#{i}:#{note}").join('\n')
    
  robot.respond /remove\s+notes?\s+*\s+(\d)\s*$/, (res) ->
    #userID=res.envelope.user.id
    category=res.match[1]
    index=parseInt res.match[2]
    notes=robot.brain.get(BRAIN_KEY) || {}
    myNotes=notes[category] || []
    removed = myNotes.splice index, 1
    if removed.length == 0
      res.reply '該当する番号のメモはありません'
      return
    notes[category]=myNotes
    robot.brain.set BRAIN_KEY, notes
    robot.brain.save()
    res.reply "削除しました: `#{category}:#{removed[0]}`"
