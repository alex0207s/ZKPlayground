// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "src/hw0/MerkleTree.sol";

interface IHW0 {
    function solved1(address) external returns (bool);
    function solved2(address) external returns (bool);
    function merkleProof(bytes32[] memory) external;
}

contract HW0Test is Test {
    IHW0 public hw0;
    MerkleTree public tree;
    address alex = vm.envAddress("MY_ADDRESS");

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

    function setUp() public {
        hw0 = IHW0(vm.envAddress("CONTRACT_ADDRESS"));
        tree = new MerkleTree(elements);
    }

    function testSolution() public {
        vm.startPrank(alex);

        (bool res,) = vm.envAddress("CONTRACT_ADDRESS").call{value: 0.001 ether}("");
        require(res, "Fail to transfer ETH!");
        assertEq(hw0.solved1(alex), true);

        hw0.merkleProof(tree.getProof(0));
        assertEq(hw0.solved2(alex), true);

        vm.stopPrank();
    }
}
