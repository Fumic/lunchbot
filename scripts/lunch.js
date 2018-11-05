'use strict';

module.exports = robot => {

  BRAIN_KEY='notes'
  robot.respond /add¥s+note¥s+(.+)¥s*$¥, (res) =>
    userID=res.envelope.user.id
    text=res.match[1]
    notes=robot.brain.get(BRAIN_KEY)||{}
    myNotes=notes[userID] || []
    myNotes.push text
    notes[userID]=myNotes
    robot.brain.set BRAIN_KEY, notes
    robot.brain.save()
    res.reply "保存しました　id: '#{myNotes.length -1}'"

  robot.hear(/^シャッフルランチ$/, async response => {
    const timeLimit = 15; // N分
    const lowerLimit = 3;

    const message = `
ランチに行きたい人は *${timeLimit}分以内* に何かしらのリアクションをつけて下さい :bento:
※全てのチームが *${lowerLimit}人以上* になるようにいい感じにチームを作ります。
`;

    const postedMessageInfo = await robot.adapter.client.web.chat.postMessage(
      response.message['room'],
      message,
      { as_user: true },
    );

    setTimeout(async () => {
      const res = await robot.adapter.client.web.reactions.get({
        timestamp: postedMessageInfo.ts,
        channel: postedMessageInfo.channel,
      });

      const uniqueUsers = Array.isArray(res.message['reactions'])
        ? [
            ...new Set(
              res.message['reactions'].reduce(
                (accumulator, currentValue) =>
                  accumulator.concat(currentValue.users),
                [],
              ),
            ),
          ]
        : [];

      for (let i = uniqueUsers.length - 1; i > 0; i--) {
        const j = Math.floor(Math.random() * (i + 1));
        [uniqueUsers[i], uniqueUsers[j]] = [uniqueUsers[j], uniqueUsers[i]];
      }

      const teamCount = Math.floor(uniqueUsers.length / lowerLimit);

      if (teamCount === 0) {
        response.send('人数が少なかったため、ランチは延期です...');
      } else {
        const teams = [];
        for (let i = 0; i < teamCount; i++) {
          teams[i] = [];
        }

        for (let i = 0; i < uniqueUsers.length; i++) {
          teams[i % teamCount].push(uniqueUsers[i]);
        }

        const message =
          'これらのチームでランチに行きましょう！\n' +
          teams
            .map(
              (team, idx) =>
                `チーム${idx + 1}: ` + team.map(user => `<@${user}>`).join(' '),
            )
            .join('\n');

        response.send(message);
      }
    }, 1000 * 60 * timeLimit);
  });
};
