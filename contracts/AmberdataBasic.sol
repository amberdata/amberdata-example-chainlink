pragma solidity >=0.4.21 <0.6.0;

import "./ChainlinkClient.sol";

contract AmberdataBasic is ChainlinkClient, Ownable {
  uint256 constant private ORACLE_PAYMENT = 1 * LINK; // solium-disable-line zeppelin/no-arithmetic-operations
  uint256 public currentGasPrice;

  constructor() Ownable() public {
    setPublicChainlinkToken();
  }

  function requestGasPrice(address _oracle, bytes32 _jobId) public onlyOwner {
    Chainlink.Request memory req = buildChainlinkRequest(_jobId, address(this), this.fulfillGasPrice.selector);
    req.add("extPath", "transactions/gas/predictions");
    req.add("path", "payload.average.gasPrice");
    sendChainlinkRequestTo(_oracle, req, ORACLE_PAYMENT);
  }

  function fulfillGasPrice(bytes32 _requestId, uint256 _gasPrice)
    public
    recordChainlinkFulfillment(_requestId)
  {
    currentGasPrice = _gasPrice;
  }
}
