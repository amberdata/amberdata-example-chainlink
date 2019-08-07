pragma solidity >=0.4.21 <0.6.0;

import "./ChainlinkClient.sol";

contract AmberdataPriceBasic is ChainlinkClient, Ownable {
  uint256 constant private ORACLE_PAYMENT = 1 * LINK; // solium-disable-line zeppelin/no-arithmetic-operations
  uint256 public currentTokenPrice;

  /* constructor() Ownable() public {
    setPublicChainlinkToken();
  } */

  function requestTokenPrice(address _oracle, bytes32 _jobId, string memory _tokenAddress) public onlyOwner {
    Chainlink.Request memory req = buildChainlinkRequest(_jobId, address(this), this.fulfillTokenPrice.selector);
    req.add("extPath", concat("market/tokens/prices/", _tokenAddress, "/latest"));
    req.add("path", "payload.0.priceUSD");
    req.addInt("times", 100);
    sendChainlinkRequestTo(_oracle, req, ORACLE_PAYMENT);
  }

  function fulfillTokenPrice(bytes32 _requestId, uint256 _price)
    public
    recordChainlinkFulfillment(_requestId)
  {
    currentTokenPrice = _price;
  }

  function concat(string memory a, string memory b, string memory c) private pure returns (string memory) {
    return string(abi.encodePacked(a, b, c));
  }
}
