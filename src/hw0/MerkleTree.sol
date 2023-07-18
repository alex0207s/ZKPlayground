// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

contract MerkleTree {
    struct Node {
        bytes32 data;
        uint256 siblingsIdx;
        uint256 parentsIdx;
    }

    uint256 numLeaves;
    Node[] private node;
    bytes32[] private proof;

    constructor(string[] memory _node) {
        numLeaves = _node.length;

        // hash the leaves
        for (uint256 i; i < numLeaves; ++i) {
            _insertNode(keccak256(abi.encodePacked(_node[i])));
        }

        _buildMerkleTree();
    }

    function _insertNode(bytes32 _data) private returns (uint256 idx) {
        node.push(Node({data: _data, siblingsIdx: type(uint256).max, parentsIdx: type(uint256).max}));

        idx = node.length - 1;
    }

    function _hashPair(bytes32 a, bytes32 b) private pure returns (bytes32) {
        return a < b ? _efficientHash(a, b) : _efficientHash(b, a);
    }

    function _efficientHash(bytes32 a, bytes32 b) private pure returns (bytes32 value) {
        assembly {
            mstore(0x00, a)
            mstore(0x20, b)
            value := keccak256(0x00, 0x40)
        }
    }

    function _buildMerkleTree() private {
        uint256 n = numLeaves;
        uint256 offset = 0;

        while (n != 1) {
            for (uint256 i; i < n; i += 2) {
                if (n % 2 == 1 && i == n - 1) {
                    // if the number of nodes is odd, then the last node could not be a pair
                    node[offset + i].parentsIdx = _insertNode(node[offset + i].data);
                } else {
                    node[offset + i].siblingsIdx = offset + i + 1;
                    node[offset + i + 1].siblingsIdx = offset + i;
                    node[offset + i].parentsIdx = node[offset + i + 1].parentsIdx =
                        _insertNode(_hashPair(node[offset + i].data, node[offset + i + 1].data));
                }
            }

            offset += n;
            n = n / 2 + n % 2;
        }
    }

    function getRoot() public view returns (bytes32) {
        return node[node.length - 1].data;
    }

    function getProof(uint256 leafIndex) public returns(bytes32[] memory) {
        require(leafIndex < numLeaves, "MerkleTree: Out of the Index!");

        delete proof; // initialize proof 
        uint256 currentIdx = leafIndex;
        while (node[currentIdx].parentsIdx < node.length) {
            if (node[currentIdx].siblingsIdx < node.length) {
                proof.push(node[node[currentIdx].siblingsIdx].data);
            }
            currentIdx = node[currentIdx].parentsIdx;
        }
        return proof;
    }
}
