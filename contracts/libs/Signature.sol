// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library Signature {

    /**
     * @dev Splits signature
     */
    function splitSignature(bytes memory _sig) private pure returns (uint8 v, bytes32 r, bytes32 s) {
        require(_sig.length == 65);

        assembly {
            // first 32 bytes, after the length prefix.
            r := mload(add(_sig, 32))
            // second 32 bytes.
            s := mload(add(_sig, 64))
            // final byte (first byte of the next 32 bytes).
            v := byte(0, mload(add(_sig, 96)))
        }

        return (v, r, s);
    }

    /**
     * @dev Recovers signer
     */
    function recoverSigner(bytes32 _message, bytes memory _sig) internal pure returns (address) {
        (uint8 v, bytes32 r, bytes32 s) = splitSignature(_sig);

        return ecrecover(_message, v, r, s);
    }

    /**
     * @dev Builds a prefixed hash to mimic the behavior of eth_sign.
     */
    function prefixed(bytes32 _hash) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", _hash));
    }

}