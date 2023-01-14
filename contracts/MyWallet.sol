// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.12;

/* solhint-disable avoid-low-level-calls */
/* solhint-disable no-inline-assembly */
/* solhint-disable reason-string */

import '@account-abstraction/contracts/core/BaseWallet.sol';
import '@openzeppelin/contracts/utils/cryptography/ECDSA.sol';
import "./EllipticCurve.sol";

interface IVerifier {
  function verifyProof(
    uint256[2] memory a,
    uint256[2][2] memory b,
    uint256[2] memory c,
    uint256[2] memory input
  ) external view returns (bool);
}

/**
 * minimal wallet.
 *  this is sample minimal wallet.
 *  has execute, eth handling methods
 *  has a single signer that can send requests through the entryPoint.
 */
contract MyWallet is BaseWallet {
  using ECDSA for bytes32;
  using UserOperationLib for UserOperation;

  //explicit sizes of nonce, to fit a single storage cell with "owner"
  uint96 private _nonce;
  address public owner;
  address public verifierAddr;
  uint256 public root;
  uint256 public lastUsedTime = 0;
  uint[2] qValues;
  address ellipticCurve;

  function nonce() public view virtual override returns (uint256) {
    return _nonce;
  }

  function entryPoint() public view virtual override returns (IEntryPoint) {
    return _entryPoint;
  }

  IEntryPoint private _entryPoint;

  event EntryPointChanged(address indexed oldEntryPoint, address indexed newEntryPoint);

  // solhint-disable-next-line no-empty-blocks
  receive() external payable {}

  constructor(IEntryPoint anEntryPoint, address anOwner, uint _root, uint[2] memory _qValues, address _ellipticCurve) {
    _entryPoint = anEntryPoint;
    owner = anOwner;
    root = _root;
    verifierAddr = 0x9Bd0782Cc9C70a57aCAc290077a7e0fc8A4E7C4B;
    qValues = _qValues;
    ellipticCurve = _ellipticCurve;
  }

  modifier onlyOwner() {
    _onlyOwner();
    _;
  }
 
  modifier isValidProof(
    uint256[2] memory a,
    uint256[2][2] memory b,
    uint256[2] memory c,
    uint256[2] memory input
  ) {
    require(IVerifier(verifierAddr).verifyProof(a, b, c, input), 'invalid proof');
    require(input[0] == root, "invalid root");
    require(input[1] > lastUsedTime, "old OTP");
    _;
    lastUsedTime = input[1];
  }


   function isProofValid(
    uint256[2] memory a,
    uint256[2][2] memory b,
    uint256[2] memory c,
    uint256[2] memory input
  ) private isValidProof(a, b, c, input) returns (bool) {
    return true;
  }


  function testTransfer(
    uint256[2] memory a,
    uint256[2][2] memory b,
    uint256[2] memory c,
    uint256[2] memory input,
    address to,
    uint256 value
  ) public isValidProof(a, b, c, input) {
    payable(to).transfer(value);
  }

  function setMerkleRootAndVerifier(uint256 _root, address _verifier) external {
    root = _root;
    verifierAddr = _verifier;
  }

  function _onlyOwner() internal view {
    //directly from EOA owner, or through the entryPoint (which gets redirected through execFromEntryPoint)
    require(msg.sender == owner || msg.sender == address(this), 'only owner');
  }

  /**
   * transfer eth value to a destination address
   */
  function transfer(address payable dest, uint256 amount) external onlyOwner {
    dest.transfer(amount);
  }

  /**
   * execute a transaction (called directly from owner, not by entryPoint)
   */
  function exec(
    address dest,
    uint256 value,
    bytes[] calldata func
  ) external onlyOwner {
    (uint256[2] memory a, uint256[2][2] memory b, uint256[2] memory c, uint256[2] memory input) = abi.decode(
      func[1],
      (uint256[2], uint256[2][2], uint256[2], uint256[2])
    );
    require(isProofValid(a, b, c, input), "Invalid proof");
    _call(dest, value, func[0]);
  }

  /**
   * execute a sequence of transaction
   */
  function execBatch(address[] calldata dest, bytes[] calldata func) external onlyOwner {
    require(dest.length == func.length, 'wrong array lengths');
    for (uint256 i = 0; i < dest.length; i++) {
      _call(dest[i], 0, func[i]);
    }
  }

  /**
   * change entry-point:
   * a wallet must have a method for replacing the entryPoint, in case the the entryPoint is
   * upgraded to a newer version.
   */
  function _updateEntryPoint(address newEntryPoint) internal override {
    emit EntryPointChanged(address(_entryPoint), newEntryPoint);
    _entryPoint = IEntryPoint(payable(newEntryPoint));
  }

  function _requireFromAdmin() internal view override {
    _onlyOwner();
  }

  /**
   * validate the userOp is correct.
   * revert if it doesn't.
   * - must only be called from the entryPoint.
   * - make sure the signature is of our supported signer.
   * - validate current nonce matches request nonce, and increment it.
   * - pay prefund, in case current deposit is not enough
   */
  function _requireFromEntryPoint() internal view override {
    require(msg.sender == address(entryPoint()), 'wallet: not from EntryPoint');
  }

  // function doEncodeStuff(proofparam1, _number, _str2, calldataOfDest) view {

  //     return (abi.encode(proofparam1, _number, _str2, calldataOfDest));
  // }

  // called by entryPoint, only after validateUserOp succeeded.
  function execFromEntryPoint(
    address dest,
    uint256 value,
    bytes calldata func
  ) external {
    // _requireFromEntryPoint();
    // (uint256[2] memory a, uint256[2][2] memory b, uint256[2] memory c, uint256[2] memory d) = abi.decode(
    //   func,
    //   (uint256[2], uint256[2][2], uint256[2], uint256[2])
    // );
    // testTransfer(a, b, c, d, dest, value);
    _call(dest, value, func);
  }

  function zkProof(
    uint256[2] memory a,
    uint256[2][2] memory b,
    uint256[2] memory c,
    uint256[2] memory d,
    uint256 value,
    address dest
  ) external {
    testTransfer(a, b, c, d, dest, value);
  }

  /// implement template method of BaseWallet
  function _validateAndUpdateNonce(UserOperation calldata userOp) internal override {
    require(_nonce++ == userOp.nonce, 'wallet: invalid nonce');
  }

  /// implement template method of BaseWallet
  function _validateSignature(
    UserOperation calldata userOp,
    bytes32 requestId,
    address
  ) internal view virtual override {
  }

  function _call(
    address target,
    uint256 value,
    bytes memory data
  ) internal {
    (bool success, bytes memory result) = target.call{value: value}(data);
    if (!success) {
      assembly {
        revert(add(result, 32), mload(result))
      }
    }
  }

  /**
   * check current wallet deposit in the entryPoint
   */
  function getDeposit() public view returns (uint256) {
    return entryPoint().balanceOf(address(this));
  }

  /**
   * deposit more funds for this wallet in the entryPoint
   */
  function addDeposit() public payable {
    (bool req, ) = address(entryPoint()).call{value: msg.value}('');
    require(req);
  }

  /**
   * withdraw value from the wallet's deposit
   * @param withdrawAddress target to send to
   * @param amount to withdraw
   */
  function withdrawDepositTo(address payable withdrawAddress, uint256 amount) public onlyOwner {
    entryPoint().withdrawTo(withdrawAddress, amount);
  }
}