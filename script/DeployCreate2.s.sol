// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.20;

import {Script, console2} from "forge-std/Script.sol";
import {DelphAI} from "../src/DelphAI.sol";

/**
 * @title DeployDelphAICreate2
 * @notice Deploy DelphAI with CREATE2 for deterministic addresses across chains
 * @dev Uses a salt to generate the same address on any chain
 */
contract DeployDelphAICreate2 is Script {

    /// @notice Default deployment parameters
    uint256 constant DEFAULT_CREATION_FEE = 0.001 ether;

    /// @notice Salt for CREATE2 (change this to get different addresses)
    bytes32 constant SALT = keccak256("DelphAI-v1.0.0");

    function run() external returns (DelphAI, address) {
        // Load environment variables
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address owner = vm.envOr("OWNER_ADDRESS", vm.addr(deployerPrivateKey));
        address resolver = vm.envOr("RESOLVER_ADDRESS", vm.addr(deployerPrivateKey));
        uint256 creationFee = vm.envOr("CREATION_FEE", DEFAULT_CREATION_FEE);

        address deployer = vm.addr(deployerPrivateKey);

        console2.log("========================================");
        console2.log("DelphAI CREATE2 Deployment");
        console2.log("========================================");
        console2.log("Deployer:", deployer);
        console2.log("Owner:", owner);
        console2.log("Resolver:", resolver);
        console2.log("Creation Fee:", creationFee);
        console2.log("Salt:", vm.toString(SALT));

        // Predict the address before deployment
        bytes32 initCodeHash = keccak256(abi.encodePacked(
            type(DelphAI).creationCode,
            abi.encode(owner, resolver, creationFee)
        ));

        address predictedAddress = computeCreate2Address(SALT, initCodeHash, deployer);

        console2.log("Predicted Address:", predictedAddress);
        console2.log("========================================");

        vm.startBroadcast(deployerPrivateKey);

        // Deploy using CREATE2
        DelphAI delphAI = new DelphAI{salt: SALT}(
            owner,
            resolver,
            creationFee
        );

        vm.stopBroadcast();

        // Verify the address matches prediction
        require(address(delphAI) == predictedAddress, "Address mismatch!");

        console2.log("========================================");
        console2.log("Deployment Successful!");
        console2.log("========================================");
        console2.log("DelphAI deployed at:", address(delphAI));
        console2.log("Owner:", delphAI.owner());
        console2.log("Resolver:", delphAI.resolver());
        console2.log("Creation Fee:", delphAI.marketCreationFee());
        console2.log("========================================");
        console2.log("");
        console2.log("IMPORTANT: This address will be THE SAME on all chains!");
        console2.log("Save this address: %s", address(delphAI));
        console2.log("========================================");

        return (delphAI, predictedAddress);
    }
}

/**
 * @title PredictDelphAIAddress
 * @notice Predict the DelphAI address without deploying
 */
contract PredictDelphAIAddress is Script {

    bytes32 constant SALT = keccak256("DelphAI-v1.0.0");
    uint256 constant DEFAULT_CREATION_FEE = 0.001 ether;

    function run() external view {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address owner = vm.envOr("OWNER_ADDRESS", vm.addr(deployerPrivateKey));
        address resolver = vm.envOr("RESOLVER_ADDRESS", vm.addr(deployerPrivateKey));
        uint256 creationFee = vm.envOr("CREATION_FEE", DEFAULT_CREATION_FEE);

        address deployer = vm.addr(deployerPrivateKey);

        bytes32 initCodeHash = keccak256(abi.encodePacked(
            type(DelphAI).creationCode,
            abi.encode(owner, resolver, creationFee)
        ));

        address predictedAddress = computeCreate2Address(SALT, initCodeHash, deployer);

        console2.log("========================================");
        console2.log("DelphAI CREATE2 Address Prediction");
        console2.log("========================================");
        console2.log("Deployer:", deployer);
        console2.log("Owner:", owner);
        console2.log("Resolver:", resolver);
        console2.log("Salt:", vm.toString(SALT));
        console2.log("========================================");
        console2.log("Predicted Address:", predictedAddress);
        console2.log("========================================");
        console2.log("");
        console2.log("This will be the address on ALL chains!");
        console2.log("========================================");
    }
}
