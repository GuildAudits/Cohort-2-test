// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ERC721URIStorage, ERC721} from "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import {Credibility} from "./CredToken.sol";
import {IOneShot} from "./interfaces/IOneShot.sol";
import {Streets} from "./Streets.sol";

contract OneShot is IOneShot, ERC721URIStorage, Ownable {
    uint256 private _nextTokenId;
    Streets private _streetsContract;

    // Mapping from token ID to its stats
    mapping(uint256 => RapperStats) public rapperStats;

    constructor() ERC721("Rapper", "RPR") Ownable(msg.sender) {}

    // configures streets contract address
    function setStreetsContract(address streetsContract) public onlyOwner {
        _streetsContract = Streets(streetsContract);
    }

    modifier onlyStreetContract() {
        require(msg.sender == address(_streetsContract), "Not the streets contract");
        _;
    }

    function mintRapper() public {
        uint256 tokenId = _nextTokenId++;
        _safeMint(msg.sender, tokenId);

        // Initialize metadata for the minted token
        rapperStats[tokenId] =
            RapperStats({weakKnees: true, heavyArms: true, spaghettiSweater: true, calmAndReady: false, battlesWon: 0});
    }

    function updateRapperStats(
        uint256 tokenId,
        bool weakKnees,
        bool heavyArms,
        bool spaghettiSweater,
        bool calmAndReady,
        uint256 battlesWon
    ) public onlyStreetContract {
        RapperStats storage metadata = rapperStats[tokenId];
        metadata.weakKnees = weakKnees;
        metadata.heavyArms = heavyArms;
        metadata.spaghettiSweater = spaghettiSweater;
        metadata.calmAndReady = calmAndReady;
        metadata.battlesWon = battlesWon;
    }

    /*//////////////////////////////////////////////////////////////
                                  VIEW
    //////////////////////////////////////////////////////////////*/
    function getRapperStats(uint256 tokenId) public view returns (RapperStats memory) {
        return rapperStats[tokenId];
    }

    function getNextTokenId() public view returns (uint256) {
        return _nextTokenId;
    }
}
