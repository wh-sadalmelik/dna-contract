// Load dependencies
const { expect } = require("chai");
// Load compiled artifacts
const DNA = artifacts.require("DNA");

contract("DNA", function () {
  let dna = {};
  beforeEach(async function () {
    // 为每个测试部署一个新的DNA合约
    dna = await DNA.deployed();
  });

  // 测试用例
  it("Get All generatorDna ", async () => {
    // 这里我是真的不知道怎么写那个except逻辑,但是应该可以通过判断数组内容来except.to.be(true)
    console.log(await dna.tokenURI(32));
    console.log(await dna.tokenURI(132));
  });
});
