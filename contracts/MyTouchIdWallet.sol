// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.12;

/* solhint-disable avoid-low-level-calls */
/* solhint-disable no-inline-assembly */
/* solhint-disable reason-string */

import '@account-abstraction/contracts/core/BaseWallet.sol';
import '@openzeppelin/contracts/utils/cryptography/ECDSA.sol';
import "./EllipticCurve.sol";

contract MyTouchIdWallet is BaseWallet {
  using ECDSA for bytes32;
  using UserOperationLib for UserOperation;

  //explicit sizes of nonce, to fit a single storage cell with "owner"
  uint96 private _nonce;
  address public owner;
  uint[2] qValues;
  address ellipticCurve;
  mapping(bytes => uint8) isSignatureUnique;

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

  constructor(IEntryPoint anEntryPoint, address anOwner,  uint[2] memory _qValues, address _ellipticCurve) {
    _entryPoint = anEntryPoint;
    owner = anOwner;
    qValues = _qValues;
    ellipticCurve = _ellipticCurve;
  }

  modifier onlyOwner() {
    _onlyOwner();
    _;
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

  // called by entryPoint, only after validateUserOp succeeded.
  function execFromEntryPoint(
    address dest,
    uint256 value,
    bytes calldata func
  ) external {
    _requireFromEntryPoint();
    _call(dest, value, func);
  }

  function _validateAndUpdateNonce(UserOperation calldata userOp) internal override {
    require(_nonce++ == userOp.nonce, 'wallet: invalid nonce');
    isSignatureUnique[userOp.signature] = 1;
  }

  /// implement template method of BaseWallet
  /*
   * Custom verification logic for secp256r1 based signatures
   */
  function _validateSignature(
    UserOperation calldata userOp,
    bytes32 requestId,
    address
  ) internal virtual view override {
    (uint r, uint s, bytes32 message) = abi.decode(userOp.signature, (uint, uint, bytes32));
    require(isSignatureUnique[userOp.signature] == 0, "Reverted due to signature replay!");
    bool success =  EllipticCurve(ellipticCurve).validateSignature(message,[r,s],qValues);
    require(success, "Signature verification failed");
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