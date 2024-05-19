// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";

interface IOneShot is IERC721 {
    struct RapperStats {
        bool weakKnees;
        bool heavyArms;
        bool spaghettiSweater;
        bool calmAndReady;
        uint256 battlesWon;
    }

    // Mint a new rapper token
    function mintRapper() external;

    // Add functions for direct metadata manipulation
    function getRapperStats(uint256 tokenId) external view returns (RapperStats memory);

    // Update metadata for a token
    function updateRapperStats(
        uint256 tokenId,
        bool weakKnees,
        bool heavyArms,
        bool spaghettiSweater,
        bool calmAndReady,
        uint256 battlesWon
    ) external;
}
