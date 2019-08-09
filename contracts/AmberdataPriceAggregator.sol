pragma solidity >=0.4.21 <0.6.0;

import "./ChainlinkClient.sol";

contract AmberdataPriceAggregator is ChainlinkClient, Ownable {
  uint256 constant private ORACLE_PAYMENT = 1 * LINK; // solium-disable-line zeppelin/no-arithmetic-operations
  mapping(bytes32 => uint256) public currentTokensPrice;
  mapping(bytes32 => uint256[]) public historicalTokensPrice;
  mapping(bytes32 => bytes32) internal receipts;

  /* constructor() Ownable() public {
    setPublicChainlinkToken();
  } */

  function requestTokenPrice(address _oracle, bytes32 _jobId, string memory _hash) public {
    Chainlink.Request memory req = buildChainlinkRequest(_jobId, address(this), this.fulfillTokenPrice.selector);
    req.add("extPath", concat("market/tokens/prices/", _hash, "/latest"));
    req.add("path", "payload.0.priceUSD");
    req.addInt("times", 100);
    receipts[sendChainlinkRequestTo(_oracle, req, ORACLE_PAYMENT)] = stringToBytes32(_hash);
  }

  function fulfillTokenPrice(bytes32 _requestId, uint256 _price)
    public
    recordChainlinkFulfillment(_requestId)
    {
      bytes32 tokenHash = receipts[_requestId];
      delete receipts[_requestId];
      currentTokensPrice[tokenHash] = _price;
      historicalTokensPrice[tokenHash].push(_price);
    }

  function getCurrentPriceByAddress(string memory _hash) public view returns (uint256) {
    return currentTokensPrice[stringToBytes32(_hash)];
  }

  function getHistoricalPriceByAddress(string memory _hash) public view returns (uint256[] memory) {
    return historicalTokensPrice[stringToBytes32(_hash)];
  }

  function concat(string memory a, string memory b, string memory c) private pure returns (string memory) {
    return string(abi.encodePacked(a, b, c));
  }

  function stringToBytes32(string memory source) internal pure returns (bytes32 result) {
    bytes memory tempEmptyStringTest = bytes(source);
    if (tempEmptyStringTest.length == 0) {
        return 0x0;
    }

    assembly {
        result := mload(add(source, 32))
    }
  }
}
