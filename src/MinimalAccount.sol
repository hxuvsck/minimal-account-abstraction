// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import {IAccount} from "lib/account-abstraction/contracts/interfaces/IAccount.sol";
import {PackedUserOperation} from "lib/account-abstraction/contracts/interfaces/PackedUserOperation.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
// mostly not dealing with signature stuff, it's just when doing accounts that we do.
import {MessageHashUtils} from "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";
import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import {SIG_VALIDATION_FAILED, SIG_VALIDATION_SUCCESS} from "lib/account-abstraction/contracts/core/Helpers.sol";
// import the entry point interface after declaring variable and connecting within the constructor
import {IEntryPoint} from "lib/account-abstraction/contracts/interfaces/IEntryPoint.sol";

contract MinimalAccount is IAccount, Ownable {
    error MinimalAccount__NotFromEntryPoint();
    error MinimalAccount__NotFromEntryPointOrOwner();

    IEntryPoint private immutable i_entryPoint;

    modifier requireFromEntryPoint() {
        if (msg.sender != address(i_entryPoint)) {
            revert MinimalAccount__NotFromEntryPoint();
        }
        _;
    }

    modifier requireFromEntryPointOwner() {
        if (msg.sender != address(i_entryPoint) && msg.sender != owner()) {
            revert MinimalAccount__NotFromEntryPointOrOwner();
        }
        _;
    }

    // uint256 ourNonce = 0; // to track nonce but actual nonce uniqueness is managed by entrypoint itself

    constructor(IEntryPoint entryPoint) Ownable(msg.sender) {
        i_entryPoint = entryPoint;
    } // You can also make this contract ownership transferable to different wallets.

    // some point, the EntryPoint contract will call this contract
    // https://eips.ethereum.org/EIPS/eip-4337
    // https://etherscan.deth.net/address/0x0576a174D229E3cFA37253523E645A78A0C91B57 for interaction with EIP-4337
    // which it gets ops tuple and packedOperations
    // https://github.com/eth-infinitism/account-abstraction using the interfaces of them rather than writing our ownselves.

    /*//////////////////////////////////////////////////////////////
                           EXTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /**
     *
     * @param dest
     * @param value
     * @param functionData
     */
    function execute(address dest, uint256 value, bytes calldata functionData) external requireFromEntryPoint {}

    // A signature is valid, if it's the contract (Minimal Account) owner
    // A function that will be called in Entry Point
    function validateUserOp(PackedUserOperation calldata userOp, bytes32 userOpHash, uint256 missingAccountFunds)
        external
        requireFromEntryPoint
        returns (uint256 validationData)
    {
        validationData = _validateSignature(userOp, userOpHash);
        //_validateNonce() <== managed with entrypoint
        _payPrefund(missingAccountFunds);
    }

    // EIP-191 vesrion of the signed hash
    function _validateSignature(PackedUserOperation calldata userOp, bytes32 userOpHash)
        internal
        view
        returns (uint256 validationData)
    {
        bytes32 ethSignedMessageHash = MessageHashUtils.toEthSignedMessageHash(userOpHash); // now the userOpHash is correct format for digestion of EIP-191 by using utils of message hashing on openzeppelin.
        address signer = ECDSA.recover(ethSignedMessageHash, userOp.signature);
        if (signer != owner()) {
            return SIG_VALIDATION_FAILED;
        }
        return SIG_VALIDATION_SUCCESS; // these two are implemented in Helper.sol in accoun abstraction playbook
    }

    function _payPrefund(uint256 missingAccountFunds) internal {
        if (missingAccountFunds != 0) {
            (bool success,) = payable(msg.sender).call{value: missingAccountFunds, gas: type(uint256).max}("");
            (success);
        }
    }

    /*//////////////////////////////////////////////////////////////
                           INTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /*//////////////////////////////////////////////////////////////
                            GETTER FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    function getEntryPoint() external view returns (address) {
        return address(i_entryPoint);
    }
}
