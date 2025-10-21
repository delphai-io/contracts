// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.20;

import {Script, console2} from "forge-std/Script.sol";
import {DelphAI} from "../src/DelphAI.sol";

/**
 * @title DeployDelphAI
 * @notice Deployment script for DelphAI contract
 * @dev Usage:
 *      forge script script/Deploy.s.sol:DeployDelphAI --rpc-url <RPC_URL> --broadcast --verify
 */
contract DeployDelphAI is Script {

    /// @notice Default deployment parameters
    uint256 constant DEFAULT_CREATION_FEE = 0.001 ether;

    function run() external returns (DelphAI) {
        // Load environment variables
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address owner = vm.envOr("OWNER_ADDRESS", vm.addr(deployerPrivateKey));
        address resolver = vm.envOr("RESOLVER_ADDRESS", vm.addr(deployerPrivateKey));
        uint256 creationFee = vm.envOr("CREATION_FEE", DEFAULT_CREATION_FEE);

        console2.log("Deploying DelphAI...");
        console2.log("Deployer:", vm.addr(deployerPrivateKey));
        console2.log("Owner:", owner);
        console2.log("Resolver:", resolver);
        console2.log("Creation Fee:", creationFee);

        vm.startBroadcast(deployerPrivateKey);

        DelphAI delphAI = new DelphAI(
            owner,
            resolver,
            creationFee
        );

        vm.stopBroadcast();

        console2.log("DelphAI deployed at:", address(delphAI));
        console2.log("Owner:", delphAI.owner());
        console2.log("Resolver:", delphAI.resolver());

        return delphAI;
    }
}

/**
 * @title DeployDelphAILocal
 * @notice Local deployment script with test values
 * @dev Usage: forge script script/Deploy.s.sol:DeployDelphAILocal --fork-url http://localhost:8545 --broadcast
 */
contract DeployDelphAILocal is Script {

    function run() external returns (DelphAI) {
        // Use anvil default account
        uint256 deployerPrivateKey = 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80;
        address owner = vm.addr(deployerPrivateKey);
        address resolver = vm.addr(deployerPrivateKey);

        console2.log("Deploying DelphAI locally...");
        console2.log("Deployer:", vm.addr(deployerPrivateKey));
        console2.log("Owner:", owner);
        console2.log("Resolver:", resolver);

        vm.startBroadcast(deployerPrivateKey);

        DelphAI delphAI = new DelphAI(
            owner,
            resolver,
            0.001 ether  // 0.001 ETH creation fee
        );

        vm.stopBroadcast();

        console2.log("DelphAI deployed at:", address(delphAI));

        return delphAI;
    }
}
