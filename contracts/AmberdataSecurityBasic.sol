pragma solidity >=0.4.21 <0.6.0;

import "./ChainlinkClient.sol";

contract AmberdataSecurityBasic is ChainlinkClient, Ownable {
  uint256 constant private ORACLE_PAYMENT = 1 * LINK; // solium-disable-line zeppelin/no-arithmetic-operations
  bytes32 public securityAuditGrade;
  uint256 public securityAuditScore;

  /* constructor() Ownable() public {
    setPublicChainlinkToken();
  } */

  function requestSecurityGrade(address _oracle, bytes32 _jobId, string memory _hash) public {
    Chainlink.Request memory req = buildChainlinkRequest(_jobId, address(this), this.fulfillSecurityGrade.selector);
    req.add("extPath", concat("contracts/", _hash, "/audit"));
    req.add("path", "payload.score.name");
    sendChainlinkRequestTo(_oracle, req, ORACLE_PAYMENT);
  }

  function requestSecurityScore(address _oracle, bytes32 _jobId, string memory _hash) public {
    Chainlink.Request memory req = buildChainlinkRequest(_jobId, address(this), this.fulfillSecurityScore.selector);
    req.add("extPath", concat("contracts/", _hash, "/audit"));
    req.add("path", "payload.score.total");
    sendChainlinkRequestTo(_oracle, req, ORACLE_PAYMENT);
  }

  function fulfillSecurityScore(bytes32 _requestId, uint256 _score)
    public
    recordChainlinkFulfillment(_requestId)
  {
    securityAuditScore = _score;
  }

  function fulfillSecurityGrade(bytes32 _requestId, bytes32 _grade)
    public
    recordChainlinkFulfillment(_requestId)
  {
    securityAuditGrade = _grade;
  }

  function concat(string memory a, string memory b, string memory c) private pure returns (string memory) {
    return string(abi.encodePacked(a, b, c));
  }
}
