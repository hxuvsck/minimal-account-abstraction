// SPDX-License-Identifier: MIT

import {Script} from "forge-std/Script.sol";
import {PackedUserOperation} from "lib/account-abstraction/contracts/interfaces/PackedUserOperation.sol";

pragma solidity ^0.8.18;

contract SendPackedUserOp {
    // we will test our signature over here, and other crates over to test file
    function run() public {}

    function generatedSignedUserOperation(bytes memory callData, address sender,) public return(PackedUserOperation memory) {
        // 1. Generate unsigned data
        uint256 nonce = vm.getNonce(sender);
        PackedUserOperation memory unsignedUserOp = _generatedSignedUserOperation(callData, sender, nonce);
        // 2. Sign it, return it

    }

    function _generateUnsignedUserOperation(bytes memory callData. address sender, uint256 nonce, ) internal pure returns(PackedUserOperation memory) {
        uint128 verificationGasLimit = 16777216;
        uint128 callGasLimit = verificationGasLimit;
        uint128 maxPriorityFeePerGas = 256;
        uint128 maxFeePerGas = maxPriorityFeePerGas;
        return PackedUserOperation{
            sender: sender,
            nonce: nonce,
            initCode: hex"", // not gonna initialize any contract by this project, so left blank
            callData: callData,
            accountGasLimits: bytes32(uint128(verificationGasLimit)<<128 | callGasLimit),
            preVerificationGas: verificationGasLimit,
            gasFees: bytes32(uint256(maxPriorityFeePerGas)<<128 | maxFeePerGas),
            paymasterAndData: hex"",
            signature: hex""
            // this is essentialy just a struct
        }
    }
}
