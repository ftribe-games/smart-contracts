// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/presets/ERC20PresetFixedSupply.sol";

contract F2CToken is Ownable, ERC20PresetFixedSupply {

    mapping(address => bool) public whales;

    bool public antiWhaleEnabled;

    uint256 public antiWhaleTime;
    uint256 public antiWhaleAmount;

    constructor(string memory _name, string memory _symbol, uint256 _initialSupply)
        ERC20PresetFixedSupply(_name, _symbol, _initialSupply, _msgSender())
    {}

    function _transfer(address _sender, address _recipient, uint256 _amount) internal virtual override {
        if (antiWhaleTime > block.timestamp && _amount > antiWhaleAmount && whales[_sender]) {
            revert("Anti Whale");
        }

        super._transfer(_sender, _recipient, _amount);
    }

    function setWhale(address _account) external onlyOwner {
        require(!whales[_account], "F2CToken: account was set");

        whales[_account] = true;
    }

    function antiWhale(uint256 _amount) external onlyOwner {
        require(!antiWhaleEnabled, "F2CToken: anti whale was enabled");

        require(_amount > 0, "F2CToken: amount is invalid");

        antiWhaleEnabled = true;

        antiWhaleAmount = _amount;

        antiWhaleTime = block.timestamp + 15 minutes;
    }

}