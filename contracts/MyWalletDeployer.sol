// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.12;

import "./MyWallet.sol";

/**
 * a sampler deployer contract for SimpleWallet
 * the "initCode" for a wallet hold its address and a method call (deployWallet) with parameters, not actual constructor code.
 */
contract MyWalletDeployer {
    function deployWallet(
        IEntryPoint entryPoint,
        address owner,
		uint256 root,
        uint256 salt,
        uint256[2] memory _qValues, 
        address _ellipticCurve
    ) public returns (MyWallet) {
        return new MyWallet{salt: bytes32(salt)}(entryPoint, owner, root, _qValues, _ellipticCurve);
    }

    function getDeploymentAddress(
        IEntryPoint entryPoint,
        address owner,
        uint256 root,
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
                                    type(MyWallet).creationCode,
                                    abi.encode(entryPoint, owner, root, _qValues, _ellipticCurve)
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