// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import {Streets} from "./Streets.sol";

contract Credibility is ERC20, Ownable {
    Streets private _streetsContract;

    constructor() ERC20("Credibility", "CRED") Ownable(msg.sender) {}

    function setStreetsContract(address streetsContract) public onlyOwner {
        _streetsContract = Streets(streetsContract);
    }

    modifier onlyStreetContract() {
        require(msg.sender == address(_streetsContract), "Not the streets contract");
        _;
    }

    function mint(address to, uint256 amount) public onlyStreetContract {
        _mint(to, amount);
    }
}
