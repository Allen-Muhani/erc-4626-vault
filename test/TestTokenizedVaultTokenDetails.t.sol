// SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";
import {TokenizedVault} from "../src/TokenizedVault.sol";

contract TestTokenizedVaultTokenDetails is Test {
    TokenizedVault vault;

    address mockAsset = address(0x1234567890123456789012345678901234567890);
    uint256 feeBasisPoints = 500; // 5% fee in basis points
    string name = "Tokenized Vault Ocean Token";
    string symbol = "tvOCT";

    function setUp() external {
        vault = new TokenizedVault(mockAsset, feeBasisPoints, name, symbol);
    }

    function test_TokenDetails() external view {
        // Verify the token details
        assertEq(vault.name(), name);
        assertEq(vault.symbol(), symbol);
        assertEq(vault.asset(), mockAsset);
        assertEq(vault.getFeeBasePoints(), feeBasisPoints);
        assertEq(vault.vaultOwner(), address(this));
    }

    function test_UpdateFeeBasePoints() public {
        uint256 newFeeBasisPoints = 300; // 3% fee in basis points
        vault.updateFeeBasePoints(newFeeBasisPoints);
        assertEq(vault.getFeeBasePoints(), newFeeBasisPoints);
    }
}
