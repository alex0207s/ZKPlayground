# ZK Playground HW0

## HW Statement

-   此作業（共兩題）視為「報名加分題」，每位參賽者可以自行選擇是否要參與這份作業。每組只要交一份即可。
-   做這份作業後務必到此 [Google 表單](https://docs.google.com/forms/d/e/1FAIpQLScW1Wlwk-i-C9tJkmaSuTc8bK7hN2E8gTuGBHmjGcdmRrAf9w/viewform) 填寫你的「錢包地址」與資料，請注意這個錢包地址將作為「回答 HW0 的智能合約題目」和「查詢你的 HW0 成績」用。

HW0 之合約部分程式碼如下：

```code=solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;
import "@openzeppelin/contracts/access/Ownable.sol";

contract hw0 is Ownable {

    bool public opening;
    mapping(address => bool) public solved1;
    mapping(address => bool) public solved2;
    bytes32[] public hashes;
    bytes32 root;

    /**Problem 1: Basic Transaction */

    fallback() external payable {
        if (msg.value == 0.001 ether) {
            require(opening, "Exceed the Deadline!");
            solved1[msg.sender] = true;
        }
    }

    /**Problem 2: Merkle Proof */

    function merkleProof(bytes32[] memory proof) public {
        require(opening, "Exceed the Deadline!");
        bytes32 leaf = keccak256(abi.encodePacked("zkplayground"));
        require(verify(proof, root, leaf), "Your proof is incorrect!");
        solved2[msg.sender] = true;
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
```

## Problem1 Statement

向此 [合約](https://sepolia.etherscan.io/address/0x5c561Afb29903D14B17B8C5EA934D6760C882b7d) 匯款 0.001 ETH。

## Problem2 Statement

此題請各位完成一連串的步驟：

1. 從此 [合約](https://sepolia.etherscan.io/address/0x5c561Afb29903D14B17B8C5EA934D6760C882b7d) 中 ，根據規定架構製作此 Merkle Tree 的 Merkle Root，以及 "zkplayground" 這個字串之哈希存在在此 Merkle Tree 的 merkle proof。
    - 換句話說你需要提出一個 keccak256(abi.encodePacked("zkplayground") 存在在 hashes 中的證明。
2. 與合約中的函式 function merkleProof(bytes32[] memory proof) public 互動並通過所有的 verify 與 require。
3. Merkle Tree 的架構為從 hashes 開始依序兩兩 hash，細節如下（如果你不確定 Tree 的樣子為何，你可以確認你建出來的 Merkle Tree 的 Root 與合約中的一樣）：

```
舉例來說陣列 elements = [0, 1, 2, 3, 4, 5, 6]

則 Merkle Tree 的 leaves 為 hashes = [
    hash(elements[0]),
    hash(elements[1]),
    hash(elements[2]),
    hash(elements[3]),
    hash(elements[4]),
    hash(elements[5]),
    hash(elements[6]),
]

則 Merkle Tree 架構為：
└─ Root: 0x8d79...469e
   ├── _hashPair(_hashPair(hash(elements[0]), hash(elements[1])), _hashPair(hash(elements[2]), hash(elements[3])))
   │   ├── _hashPair(hash(elements[0]), hash(elements[1]))
   │   │    ├─ hash(elements[0])
   │   │    └─ hash(elements[1])
   │   └── _hashPair(hash(elements[2]), hash(elements[3]))
   │        ├─ hash(elements[2])
   │        └─ hash(elements[3])
   └── _hashPair(_hashPair(hash(elements[4]), hash(elements[5])), hash(elements[6]))
       ├── _hashPair(hash(elements[4]), hash(elements[5]))
       │    ├─ hash(elements[4])
       │    └─ hash(elements[5])
       └── hash(elements[6])
            └─ hash(elements[6])

本題陣列為：elements = [
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
]
```

## 完成作業後請填寫加分作業表單 [Google 表單](https://docs.google.com/forms/d/e/1FAIpQLScW1Wlwk-i-C9tJkmaSuTc8bK7hN2E8gTuGBHmjGcdmRrAf9w/viewform)
