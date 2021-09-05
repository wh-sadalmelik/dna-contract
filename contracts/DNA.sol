// SPDX-License-Identifier: MIT
pragma solidity 0.8.2;

import "../node_modules/@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "../node_modules/@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "../node_modules/@openzeppelin/contracts/access/Ownable.sol";
import "../node_modules/@openzeppelin/contracts/utils/Strings.sol";


contract DNA is ERC721Enumerable, ReentrancyGuard, Ownable {
    using Strings for uint256;
    
    string[2][4] basePair = [
        ["A", "T"],
        ["C", "G"],
        ["G", "C"],
        ["T", "A"]
    ];

    /**
     * @dev random
     */
    function _random(string memory input) internal view returns (uint256) {
        return uint256(keccak256(abi.encodePacked(block.timestamp, msg.sender, input)));
    }

    function _generatorDna(uint256 tokenId) internal view returns (string[10] memory left, string[10] memory right) {
        uint256 rand = _random(tokenId.toString());

        for (uint256 i = 0; i < 10; i++) {
            string[2] memory pairs = basePair[rand % 4];
            left[i] = pairs[0];
            right[i] = pairs[1];
            rand = rand / 10;
        }
    }

    function _generatorExtraDna(uint256 tokenId) internal view returns (string[2] memory left, string[2] memory right) {
        uint256 rand = _random(_random(tokenId.toString()).toString());
        uint256 greatness = rand % 100;

        if(greatness > 90) {
           string[2] memory pairs = basePair[rand % 4];
           left[0] = pairs[0];
           right[0] = pairs[1];
           rand = rand / 10;
           pairs = basePair[rand % 4];
           left[1] = pairs[0];
           right[1] = pairs[1];

        } else if(greatness > 80) {
           string[2] memory pairs = basePair[rand % 4];
           left[0] = pairs[0];
           right[0] = pairs[1];
           left[1] = '';
           right[1] = '';
        }

    } 

    function claim(uint256 tokenId) public nonReentrant {
         require(tokenId > 0 && tokenId < 10000, "Token ID invalid");
        _safeMint(_msgSender(), tokenId);
    }

    // 生成图
    function tokenURI(uint256 tokenId) override public view returns (string memory output) {
        string[17] memory parts;
        (string[10] memory left, string[10] memory right) = _generatorDna(tokenId);
        (string[2] memory leftExtra, string[2] memory rightExtra) = _generatorExtraDna(tokenId);

        parts[0] = '<svg xmlns="http://www.w3.org/2000/svg" preserveAspectRatio="xMinYMin meet" viewBox="0 0 350 350"><style>.base { fill: black; font-family: serif; font-size: 14px; text-anchor:middle; }</style><rect width="100%" height="100%" fill="white" />';

        for(uint256 i = 1; i < 13; i++) { 
            if(i <= 10) {
                parts[i] = string(abi.encodePacked('<text x="50%" y="' , (i * 20 + 20).toString() , '" class="base">' , left[i - 1] , '  ' , right[i - 1] , '</text>'));
            }else {
                parts[i] = string(abi.encodePacked('<text x="50%" y="' , (i * 20 + 20).toString() , '" class="base">' , leftExtra[i - 11] , '  ' , rightExtra[i - 11] , '</text>'));
            }
        }

        parts[13] = '</svg>';

        output = string(abi.encodePacked(parts[0], parts[1], parts[2], parts[3], parts[4], parts[5], parts[6], parts[7], parts[8]));
        output = string(abi.encodePacked(output, parts[9], parts[10], parts[11], parts[12], parts[13]));
        
        string memory json = Base64.encode(bytes(string(abi.encodePacked('{"name": "DNA #', tokenId.toString(), '", "description": "DNA is randomized generated and stored on chain. Stats, images, and other functionality are intentionally omitted for others to interpret. Feel free to use Loot in any way you want.", "image": "data:image/svg+xml;base64,', Base64.encode(bytes(output)), '"}'))));
        output = string(abi.encodePacked('data:application/json;base64,', json));

        return output;
    }
     

    constructor() ERC721("DNA", "DNA") Ownable() {}
}

/// [MIT License]
/// @title Base64
/// @notice Provides a function for encoding some bytes in base64
/// @author Brecht Devos <brecht@loopring.org>
library Base64 {
    bytes internal constant TABLE = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

    /// @notice Encodes some bytes to the base64 representation
    function encode(bytes memory data) internal pure returns (string memory) {
        uint256 len = data.length;
        if (len == 0) return "";

        // multiply by 4/3 rounded up
        uint256 encodedLen = 4 * ((len + 2) / 3);

        // Add some extra buffer at the end
        bytes memory result = new bytes(encodedLen + 32);

        bytes memory table = TABLE;

        assembly {
            let tablePtr := add(table, 1)
            let resultPtr := add(result, 32)

            for {
                let i := 0
            } lt(i, len) {

            } {
                i := add(i, 3)
                let input := and(mload(add(data, i)), 0xffffff)

                let out := mload(add(tablePtr, and(shr(18, input), 0x3F)))
                out := shl(8, out)
                out := add(out, and(mload(add(tablePtr, and(shr(12, input), 0x3F))), 0xFF))
                out := shl(8, out)
                out := add(out, and(mload(add(tablePtr, and(shr(6, input), 0x3F))), 0xFF))
                out := shl(8, out)
                out := add(out, and(mload(add(tablePtr, and(input, 0x3F))), 0xFF))
                out := shl(224, out)

                mstore(resultPtr, out)

                resultPtr := add(resultPtr, 4)
            }

            switch mod(len, 3)
            case 1 {
                mstore(sub(resultPtr, 2), shl(240, 0x3d3d))
            }
            case 2 {
                mstore(sub(resultPtr, 1), shl(248, 0x3d))
            }

            mstore(result, encodedLen)
        }

        return string(result);
    }
}
