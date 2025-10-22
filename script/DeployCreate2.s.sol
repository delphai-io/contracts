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
    bytes32 constant SALT = keccak256("DelphAI-v1.1.0");

    /// @notice Foundry's Create2Deployer address (same on all chains)
    address constant CREATE2_DEPLOYER = 0x4e59b44847b379578588920cA78FbF26c0B4956C;

    function run() external returns (DelphAI, address) {
        // Load environment variables
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address owner = vm.envOr("OWNER_ADDRESS", vm.addr(deployerPrivateKey));
        address resolver = vm.envOr("RESOLVER_ADDRESS", vm.addr(deployerPrivateKey));
        uint256 creationFee = vm.envOr("CREATION_FEE", DEFAULT_CREATION_FEE);

        console2.log("========================================");
        console2.log("DelphAI CREATE2 Deployment");
        console2.log("========================================");
        console2.log("Owner:", owner);
        console2.log("Resolver:", resolver);
        console2.log("Creation Fee:", creationFee);
        console2.log("Salt:", vm.toString(SALT));

        // Predict the address before deployment (using Create2Deployer)
        bytes32 initCodeHash = keccak256(abi.encodePacked(
            type(DelphAI).creationCode,
            abi.encode(owner, resolver, creationFee)
        ));

        address predictedAddress = computeCreate2Address(SALT, initCodeHash, CREATE2_DEPLOYER);

        console2.log("Predicted Address:", predictedAddress);
        console2.log("Create2Deployer:", CREATE2_DEPLOYER);
        console2.log("========================================");

        vm.startBroadcast(deployerPrivateKey);

        // Deploy using CREATE2
        DelphAI delphAI = new DelphAI{salt: SALT}(
            owner,
            resolver,
            creationFee
        );

        vm.stopBroadcast();

        console2.log("========================================");
        console2.log("Deployed Address:", address(delphAI));
        console2.log("========================================");

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

    bytes32 constant SALT = keccak256("DelphAI-v1.1.0");
    uint256 constant DEFAULT_CREATION_FEE = 0.001 ether;
    address constant CREATE2_DEPLOYER = 0x4e59b44847b379578588920cA78FbF26c0B4956C;

    function run() external view {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address owner = vm.envOr("OWNER_ADDRESS", vm.addr(deployerPrivateKey));
        address resolver = vm.envOr("RESOLVER_ADDRESS", vm.addr(deployerPrivateKey));
        uint256 creationFee = vm.envOr("CREATION_FEE", DEFAULT_CREATION_FEE);

        bytes32 initCodeHash = keccak256(abi.encodePacked(
            type(DelphAI).creationCode,
            abi.encode(owner, resolver, creationFee)
        ));

        address predictedAddress = computeCreate2Address(SALT, initCodeHash, CREATE2_DEPLOYER);

        console2.log("========================================");
        console2.log("DelphAI CREATE2 Address Prediction");
        console2.log("========================================");
        console2.log("Owner:", owner);
        console2.log("Resolver:", resolver);
        console2.log("Creation Fee:", creationFee);
        console2.log("Salt:", vm.toString(SALT));
        console2.log("========================================");
        console2.log("Predicted Address:", predictedAddress);
        console2.log("Create2Deployer:", CREATE2_DEPLOYER);
        console2.log("========================================");
        console2.log("");
        console2.log("This will be the address on ALL chains!");
        console2.log("========================================");
    }
}
