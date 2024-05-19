// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IOneShot} from "./interfaces/IOneShot.sol";
import {Credibility} from "./CredToken.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";

contract Streets is IERC721Receiver {
    // Struct to hold staking information
    struct Stake {
        uint256 startTime;
        address owner;
    }

    mapping(uint256 tokenId => Stake stake) public stakes;

    // ERC721 token contract
    IOneShot public oneShotContract;
    Credibility public credContract;

    // Event declarations
    event Staked(address indexed owner, uint256 tokenId, uint256 startTime);
    event Unstaked(address indexed owner, uint256 tokenId, uint256 stakedDuration);

    constructor(address _oneShotContract, address _credibilityContract) {
        oneShotContract = IOneShot(_oneShotContract);
        credContract = Credibility(_credibilityContract);
    }

    // Stake tokens by transferring them to this contract
    function stake(uint256 tokenId) external {
        stakes[tokenId] = Stake(block.timestamp, msg.sender);
        emit Staked(msg.sender, tokenId, block.timestamp);
        oneShotContract.transferFrom(msg.sender, address(this), tokenId);
    }

    // Unstake tokens by transferring them back to their owner
    function unstake(uint256 tokenId) external {
        require(stakes[tokenId].owner == msg.sender, "Not the token owner");
        uint256 stakedDuration = block.timestamp - stakes[tokenId].startTime;
        uint256 daysStaked = stakedDuration / 1 days;

        // Assuming RapBattle contract has a function to update metadata properties
        IOneShot.RapperStats memory stakedRapperStats = oneShotContract.getRapperStats(tokenId);

        emit Unstaked(msg.sender, tokenId, stakedDuration);
        delete stakes[tokenId]; // Clear staking info

        // Apply changes based on the days staked
        if (daysStaked >= 1) {
            stakedRapperStats.weakKnees = false;
            credContract.mint(msg.sender, 1);
        }
        if (daysStaked >= 2) {
            stakedRapperStats.heavyArms = false;
            credContract.mint(msg.sender, 1);
        }
        if (daysStaked >= 3) {
            stakedRapperStats.spaghettiSweater = false;
            credContract.mint(msg.sender, 1);
        }
        if (daysStaked >= 4) {
            stakedRapperStats.calmAndReady = true;
            credContract.mint(msg.sender, 1);
        }

        // Only call the update function if the token was staked for at least one day
        if (daysStaked >= 1) {
            oneShotContract.updateRapperStats(
                tokenId,
                stakedRapperStats.weakKnees,
                stakedRapperStats.heavyArms,
                stakedRapperStats.spaghettiSweater,
                stakedRapperStats.calmAndReady,
                stakedRapperStats.battlesWon
            );
        }

        // Continue with unstaking logic (e.g., transferring the token back to the owner)
        oneShotContract.transferFrom(address(this), msg.sender, tokenId);
    }

    // Implementing IERC721Receiver so the contract can accept ERC721 tokens
    function onERC721Received(address, address, uint256, bytes calldata) external pure override returns (bytes4) {
        return IERC721Receiver.onERC721Received.selector;
    }
}
