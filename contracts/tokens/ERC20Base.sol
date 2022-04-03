pragma solidity 0.8.13;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract ERC20Base is ERC20 {
    constructor(uint256 initialSupply) ERC20("BaseToken", "BT") {
        _mint(msg.sender, initialSupply * 10**18);
    }
}
