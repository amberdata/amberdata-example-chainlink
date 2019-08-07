pragma solidity >=0.4.21 <0.6.0;

import "./ChainlinkClient.sol";

contract AmberdataLinkBalance is ChainlinkClient, Ownable {
  uint256 constant private ORACLE_PAYMENT = 1 * LINK; // solium-disable-line zeppelin/no-arithmetic-operations
  uint256 public balance;

  function cacheBalance(address _token) public {
    LinkTokenInterface link = LinkTokenInterface(_token);
    balance = link.balanceOf(address(this));
  }

  function getBalance(address _token, address _contract) public returns(uint256) {
    LinkTokenInterface link = LinkTokenInterface(_token);
    return link.balanceOf(_contract);
  }

  function withdrawLink() public onlyOwner {
    LinkTokenInterface link = LinkTokenInterface(chainlinkTokenAddress());
    require(link.transfer(msg.sender, link.balanceOf(address(this))), "Unable to transfer");
  }
}
