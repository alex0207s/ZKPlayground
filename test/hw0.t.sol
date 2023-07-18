// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "forge-std/Test.sol";
import "forge-std/console.sol";

interface IHW0 {
    function solved1(address) external returns(bool);
    function solved2(address) external returns(bool);
    function merkleProof(bytes32[] memory) external;
}

contract HW0Test is Test {
    IHW0 public hw0;

    string[] public elements = [
        "zkplayground",
        "zkpapaya",
        "zkpeach",
        "zkpear",
        "zkpersimmon",
        "zkpineapple",
        "zkpitaya",
        "zkplum",
        "zkpomegranate",
        "zkpomelo"
    ];

    struct Node {
        bytes32 data;
        uint256 siblingsIdx;
        uint256 parentsIdx;
    }

    Node[] public hashes;
    bytes32[] public path;

    function setUp() public {
        hw0 = IHW0(0x5c561Afb29903D14B17B8C5EA934D6760C882b7d);


        // hash leaves 
        for(uint i; i < elements.length; ++i) {
            hashes.push(Node({
                data:  keccak256(abi.encodePacked(elements[i])),
                siblingsIdx: type(uint256).max,
                parentsIdx: type(uint256).max
            }));
        }
    }

    function _hashPair(bytes32 a, bytes32 b) public pure returns (bytes32) {
        return a < b ? _efficientHash(a, b) : _efficientHash(b, a);
    }

    function _efficientHash(bytes32 a, bytes32 b)
        private
        pure
        returns (bytes32 value)
    {
        assembly {
            mstore(0x00, a)
            mstore(0x20, b)
            value := keccak256(0x00, 0x40)
        }
    }

    function buildMerkleTree() private {
        uint256 n = hashes.length;
        uint256 offset = 0;

        while (n != 1) {
            for (uint i; i < n; i+=2) { 
                if (n % 2 == 1 && i == n-1) {
                    // if the number of nodes is odd, then the last node could not be a pair
                    hashes.push(Node({
                        data:  hashes[offset + i].data,
                        siblingsIdx: 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff,
                        parentsIdx: 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
                    }));
    
                    hashes[offset + i].parentsIdx = hashes.length - 1;
                } else {
                    hashes[offset + i].siblingsIdx = offset + i + 1;
                    hashes[offset + i + 1].siblingsIdx = offset + i;

                    hashes.push(Node({
                        data:  _hashPair(hashes[offset + i].data, hashes[offset + i + 1].data),
                        siblingsIdx: 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff,
                        parentsIdx: 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
                    }));

                    hashes[offset + i].parentsIdx = hashes[offset + i + 1].parentsIdx = hashes.length - 1;
                }
            }
            
            offset += n;
            n = n / 2 + n % 2;
        }
    }

    function getProof(uint256 leafIndex) public returns(bytes32[] memory) {
        require(leafIndex < elements.length, "Out of Index");

        uint256 currentIdx = leafIndex; 
        while(true) {
            if(hashes[currentIdx].siblingsIdx >= hashes.length) {
                currentIdx = hashes[currentIdx].parentsIdx;
                if(currentIdx >= hashes.length) {
                    break;
                }
                continue;
            }
            path.push(hashes[hashes[currentIdx].siblingsIdx].data);
            currentIdx = hashes[currentIdx].parentsIdx;   
        }

        return path;
    }

    function getRoot() public view returns(bytes32) {
        return hashes[hashes.length-1].data;
    }

    function test() public {
        // solution 1: Find the input data of transaction on etherscan
        // address(0x5c561Afb29903D14B17B8C5EA934D6760C882b7d).call(hex"81f0765400000000000000000000000000000000000000000000000000000000000000200000000000000000000000000000000000000000000000000000000000000004cc61ebc064488ecc9c6aa0138875f527fe4033a5b0fb9a1acf9d48f8809a82e96cba9ea971cd36a1100bbe94d254d62109b18a1eb3714c80fbbcc9ffef36974440ef6049493657f0558c92f1f64806570ebba9e20cd40eb1385d8c61b3c523c7a7a7ef787c98fd4abfa510e07a146c11dbfcc93e6a316a41cb57f0dfa2b4cbd6");

        buildMerkleTree();
        assertEq(getRoot(), 0x8d798c5764a164492f1c8850246fdd11750bd2bffd8f42356150ae85a2b5469e);
        
        hw0.merkleProof(getProof(0));
        assertEq(hw0.solved2(address(this)), true);
    }
}