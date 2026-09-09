// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import {IAccount} from "lib/account-abstraction/contracts/interfaces/IAccount.sol";

contract MinimalAccount is IAccount {
    // some point, the EntryPoint contract will call this contract
    // https://eips.ethereum.org/EIPS/eip-4337
    // https://etherscan.deth.net/address/0x0576a174D229E3cFA37253523E645A78A0C91B57 for interaction with EIP-4337
    // which it gets ops tuple and packedOperations
    // https://github.com/eth-infinitism/account-abstraction using the interfaces of them rather than writing our ownselves.

    function validateUserOp(PackedUserOperation calldata userOp, bytes32 userOpHash, uint256 missingAccountFunds)
        external
        returns (uint256 validationData);
}
