// SPDX-License-Identifier: MIT

import {Script} from "forge-std/Script.sol";
import {PackedUserOperation} from "lib/account-abstraction/contracts/interfaces/PackedUserOperation.sol";
import {HelperConfig} from "../script/HelperConfig.s.sol";
import {IEntryPoint} from "lib/account-abstraction/contracts/interfaces/IEntryPoint.sol";
import {MessageHashUtils} from "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";

pragma solidity ^0.8.18;

contract SendPackedUserOp is Script {
    using MessageHashUtils for bytes32;

    // we will test our signature over here, and other crates over to test file
    function run() public {}

    function generateSignedUserOperation(bytes memory callData, HelperConfig.NetworkConfig memory) public view returns (PackedUserOperation memory) {
        
        // 1. Generate unsigned data
        uint256 nonce = vm.getNonce(config.account);
        PackedUserOperation memory userOp = _generatedSignedUserOperation(callData, config.account, nonce);
        
        // 2. Get the user Op Hash
        bytes32 userOpHash = IEntryPoint(config.entryPoint).getUserOpHash(userOp);
        // convert it to EIP-191 friendly digesting hash
        bytes32 digest = userOpHash.toEthSignedMessageHash(); // correctly formatted hash using MessageHashUtils

        // 3. Sign it (digested hash) here
        (uint8 v, bytes32 r, bytes32 s) =vm.sign(config.account, digest); // if you insert your private key, it will be risk. So foundry as using config.account if unlocked priv key.
        //combining this value together, we will create the bottom of struct PackedUserOperation's bytes signature
        userOp.signature = abi.encodePacked(r,s,v); // check the order as not v,r,s but r,s,v...
        return userOp;

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
