const createChatId = (firstUserId, secondUserId) =>
  [String(firstUserId), String(secondUserId)].sort().join('_');

module.exports = { createChatId };
