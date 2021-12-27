// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/AccessControlEnumerable.sol";

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";

import "./../libs/Signature.sol";

contract MysteryBox is AccessControlEnumerable, ERC721Enumerable, ERC721Burnable  {

    using Signature for bytes32;

    event URIChanged(string uri);

    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant SIGNER_ROLE = keccak256("SIGNER_ROLE");

    string private _bURI;

    uint256 public chainId;

    mapping(uint256 => bool) public nonces;

    constructor(string memory _name, string memory _symbol, string memory _uri, uint256 _chainId) ERC721(_name, _symbol) {
        _bURI = _uri;
        chainId = _chainId;

        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());

        _setupRole(MINTER_ROLE, _msgSender());
        _setupRole(SIGNER_ROLE, _msgSender());
    }

    function setURI(string memory _uri) public virtual {
        require(hasRole(DEFAULT_ADMIN_ROLE, _msgSender()), "MysteryBox: must have admin role to set");

        require(bytes(_uri).length > 0, "MysteryBox: uri is invalid");

        _bURI = _uri;

        emit URIChanged(_uri);
    }

    function mint(uint256 _tokenId, address _to) public virtual {
        require(hasRole(MINTER_ROLE, _msgSender()), "MysteryBox: must have minter role to mint");

        _mint(_to, _tokenId);
    }

    function mint(uint256 _tokenId, bytes memory _signature) public virtual {
        require(!nonces[_tokenId], "MysteryBox: nonce was used");

        address msgSender = _msgSender();

        bytes32 message = keccak256(abi.encodePacked(_tokenId, msgSender, chainId, this)).prefixed();

        require(hasRole(SIGNER_ROLE, message.recoverSigner(_signature)), "MysteryBox: signature is invalid");

        nonces[_tokenId] = true;

        _mint(msgSender, _tokenId);
    }

    function mintBatch(uint256[] memory _tokenIds, address[] memory _accounts) public virtual {
        require(hasRole(MINTER_ROLE, _msgSender()), "MysteryBox: must have minter role to mint");

        uint256 length = _tokenIds.length;

        require(length > 0 && length == _accounts.length, "MysteryBox: array length is invalid");

        for (uint256 i = 0; i < length; i++) {
            _mint(_accounts[i], _tokenIds[i]);
        }
    }

    function safeTransferBatch(address _from, address[] memory _receivers, uint256[] memory _tokenIds) public virtual {
        uint256 length = _receivers.length;

        require(length > 0 && length == _tokenIds.length, "MysteryBox: array length is invalid");

        for (uint256 i = 0; i < length; i++) {
            safeTransferFrom(_from, _receivers[i], _tokenIds[i]);
        }
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return _bURI;
    }

    function _beforeTokenTransfer(address _from, address _to, uint256 _tokenId) internal virtual override(ERC721, ERC721Enumerable) {
        super._beforeTokenTransfer(_from, _to, _tokenId);
    }

    function supportsInterface(bytes4 _interfaceId) public view virtual override(AccessControlEnumerable, ERC721, ERC721Enumerable) returns (bool) {
        return super.supportsInterface(_interfaceId);
    }

}