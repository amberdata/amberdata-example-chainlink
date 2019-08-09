const fs = require('fs')
const path = require('path')

const AmberdataBasic = artifacts.require('./AmberdataBasic.sol')
const AmberdataPriceBasic = artifacts.require('./AmberdataPriceBasic.sol')
const AmberdataPriceAggregator = artifacts.require('./AmberdataPriceAggregator.sol')
const AmberdataSecurityBasic = artifacts.require('./AmberdataSecurityBasic.sol')
const AmberdataSecurityAudits = artifacts.require('./AmberdataSecurityAudits.sol')
const AmberdataLinkBalance = artifacts.require('./AmberdataLinkBalance.sol')

const contracts = [
  AmberdataBasic,
  AmberdataPriceBasic,
  AmberdataPriceAggregator,
  AmberdataSecurityBasic,
  AmberdataSecurityAudits,
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
