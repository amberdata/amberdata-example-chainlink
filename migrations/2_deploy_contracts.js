const fs = require('fs')
const path = require('path')

const AmberdataBasic = artifacts.require('./AmberdataBasic.sol')
const AmberdataPriceBasic = artifacts.require('./AmberdataPriceBasic.sol')
const AmberdataSecurityBasic = artifacts.require('./AmberdataSecurityBasic.sol')
const AmberdataLinkBalance = artifacts.require('./AmberdataLinkBalance.sol')

const contracts = [
  AmberdataBasic,
  AmberdataPriceBasic,
  AmberdataSecurityBasic,
  AmberdataLinkBalance
]

module.exports = async deployer => {
  // Deploy Each
  await contracts.forEach(async c => {
    await deployer.deploy(c).then(g => {
      console.log('Deployed Contract:', g.address)
    })
  })
}
