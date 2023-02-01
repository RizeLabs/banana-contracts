// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.12;

import "./MyTouchIdWallet.sol";

/**
 * a sampler deployer contract for SimpleWallet
 * the "initCode" for a wallet hold its address and a method call (deployWallet) with parameters, not actual constructor code.
 */
contract MyWalletDeployer {
    function deployWallet(
        IEntryPoint entryPoint,
        address owner,
        uint256 salt,
        uint256[2] memory _qValues, 
        address _ellipticCurve
    ) public returns (MyTouchIdWallet) {
        return new MyTouchIdWallet{salt: bytes32(salt)}(entryPoint, owner, _qValues, _ellipticCurve);
    }

    function getDeploymentAddress(
        IEntryPoint entryPoint,
        address owner,
        uint256 salt,
        uint256[2] memory _qValues, 
        address _ellipticCurve
    ) public view returns (address) {
        address predictedAddress = address(
            uint160(
                uint256(
                    keccak256(
                        abi.encodePacked(
                            bytes1(0xff),
                            address(this),
                            salt,
                            keccak256(
                                abi.encodePacked(
                                    type(MyTouchIdWallet).creationCode,
                                    abi.encode(entryPoint, owner, _qValues, _ellipticCurve)
                                )
                            )
                        )
                    )
                )
            )
        );

        return predictedAddress;
    }
}