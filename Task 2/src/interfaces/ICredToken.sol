// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface ICredToken {
    function decimals() external returns (uint8);

    function approve(address to, uint256 amount) external;

    function transfer(address to, uint256 amount) external;

    function transferFrom(address from, address to, uint256 amount) external;

    function balanceOf(address user) external returns (uint256 balance);
}
