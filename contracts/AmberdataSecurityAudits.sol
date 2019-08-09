pragma solidity >=0.4.21 <0.6.0;

import "./ChainlinkClient.sol";

contract AmberdataSecurityAudits is ChainlinkClient, Ownable {
  uint256 constant private ORACLE_PAYMENT = 1 * LINK; // solium-disable-line zeppelin/no-arithmetic-operations

  mapping(bytes32 => bytes32) public currentSecurityGrades;
  mapping(bytes32 => uint256) public currentSecurityTotals;
  mapping(bytes32 => bytes32) internal receipts;

  /* constructor() Ownable() public {
    setPublicChainlinkToken();
  } */

  // NOTE: Since multiple return values are not possible yet, must make 2 requests
  function requestSecurityGrade(address _oracle, bytes32 _jobIdGrade, bytes32 _jobIdTotal, string memory _hash) public {
    // Get the grade
    Chainlink.Request memory reqGrade = buildChainlinkRequest(_jobIdGrade, address(this), this.fulfillSecurityGrade.selector);
    reqGrade.add("extPath", concat("contracts/", _hash, "/audit"));
    reqGrade.add("path", "payload.score.name");
    receipts[sendChainlinkRequestTo(_oracle, reqGrade, ORACLE_PAYMENT)] = stringToBytes32(_hash);

    // Get the total
    Chainlink.Request memory reqTotal = buildChainlinkRequest(_jobIdTotal, address(this), this.fulfillSecurityTotal.selector);
    reqTotal.add("extPath", concat("contracts/", _hash, "/audit"));
    reqTotal.add("path", "payload.score.total");
    receipts[sendChainlinkRequestTo(_oracle, reqTotal, ORACLE_PAYMENT)] = stringToBytes32(_hash);
  }

  function fulfillSecurityGrade(bytes32 _requestId, bytes32 _grade)
    public
    recordChainlinkFulfillment(_requestId)
    {
      bytes32 contractHash = receipts[_requestId];
      delete receipts[_requestId];
      currentSecurityGrades[contractHash] = _grade;
    }

  function fulfillSecurityTotal(bytes32 _requestId, uint256 _total)
    public
    recordChainlinkFulfillment(_requestId)
    {
      bytes32 contractHash = receipts[_requestId];
      delete receipts[_requestId];
      currentSecurityTotals[contractHash] = _total;
    }

  function getAuditByAddress(string memory _hash) public view returns (bytes32, uint256) {
    return (
      currentSecurityGrades[stringToBytes32(_hash)],
      currentSecurityTotals[stringToBytes32(_hash)]
    );
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
