// SPDX-License-Identifier: MIT

import {Script} from "forge-std/Script.sol";
import {PackedUserOperation} from "lib/account-abstraction/contracts/interfaces/PackedUserOperation.sol";

pragma solidity ^0.8.18;

contract SendPackedUserOp {
    // we will test our signature over here, and other crates over to test file
    function run() public {}

    function generatedSignedUserOperation() public return(PackedUserOperation memory) {
        // 1. Generate unsigned data
        // 2. Sign it, return it

    }

    function _generateUnsignedUserOperation(bytes memory callData. address sender) internal pure returns(PackedUserOperation memory) {
        return PackedUserOperation{
            address sender: ;

        }
    }
}
