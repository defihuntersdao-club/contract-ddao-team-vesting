const BigNumber = require("bignumber.js");
const { time } = require("@openzeppelin/test-helpers");

function toBN(number) {
  return new BigNumber(number);
}

async function setCurrentTime(nbSeconds) {
  let newTime = toBN(await time.latest()).plus(nbSeconds);
  await time.increase(newTime.toString());
}

module.exports = {
  setCurrentTime,
};
