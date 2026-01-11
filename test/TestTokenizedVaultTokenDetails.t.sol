// SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";
import {TokenizedVault} from "../src/TokenizedVault.sol";

contract TestTokenizedVaultTokenDetails is Test {
    function test_TokenDetails() public {
        // Deploy the TokenizedVault contract
        address mockAsset = address(0x1234567890123456789012345678901234567890);
        uint256 feeBasisPoints = 500; // 5% fee in basis points
        string memory name = "Tokenized Vault Ocean Token";
        string memory symbol = "tvOCT";

        TokenizedVault vault = new TokenizedVault(mockAsset, feeBasisPoints, name, symbol);

        // Verify the token details
        assertEq(vault.name(), name);
        assertEq(vault.symbol(), symbol);
        assertEq(vault.asset(), mockAsset);
        assertEq(vault.getFeeBasePoints(), feeBasisPoints);
    }
}
