// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import "forge-std/Script.sol";
import "src/hw0/MerkleTree.sol";

interface IHW0 {
    function solved1(address) external returns (bool);
    function solved2(address) external returns (bool);
    function merkleProof(bytes32[] memory) external;
}

contract HW0Script is Script {
    IHW0 public hw0;
    MerkleTree public tree;

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

    function run() public {
        vm.startBroadcast();

        (bool res,) = vm.envAddress("CONTRACT_ADDRESS").call{value: 0.001 ether}("");
        require(res, "Fail to transfer ETH!");
        assert(hw0.solved1(vm.envAddress("MY_ADDRESS")));

        hw0.merkleProof(tree.getProof(0));
        assert(hw0.solved2(vm.envAddress("MY_ADDRESS")));

        vm.stopBroadcast();

    }
}
