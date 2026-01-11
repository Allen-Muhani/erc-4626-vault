// SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

import {ERC4626Fees} from "./ERC4626Fees.sol";
import {ERC4626} from "openzeppelin-contracts/contracts/token/ERC20/extensions/ERC4626.sol";

error ERC4626DepositExceedsMaxLimit(uint256 attempted, uint256 maxAllowed);

error ERC4626MintExceedsMaxLimit(uint256 attempted, uint256 maxAllowed);

error ERC4626WithdrawExceedsMaxLimit(uint256 attempted, uint256 maxAllowed);

error ERC4626RedeemExceedsMaxLimit(uint256 attempted, uint256 maxAllowed);

contract TokenizedVault is ERC4626Fees {
    /**
     * The owner of the vault/ the one who deployed the vault
     */
    address public vaultOwner;

    /**
     * @param assetAddress the address of the asset to be locke in the vault in exchange for shares.
     * @param basisPointsFees percentage of the asset token to be locked as entry fee or exit fee.
     * @param name the name of the vault/share token.
     * @param symbol the symbol of the vault/share token.
     */
    constructor(address assetAddress, uint256 basisPointsFees, string memory name, string memory symbol)
        ERC4626Fees(assetAddress, basisPointsFees, name, symbol)
    {
        vaultOwner = msg.sender;
    }

    /**
     * Exchanges `assets` for shares and deposits them into the vault,
     * sending the shares to `receiver`.
     * @param assets the amount of assets to exchange for shares.
     * @param receiver the address to receive the shares.
     * returns the amount of shares minted to `receiver`.
     */
    function deposit(uint256 assets, address receiver) public override returns (uint256 shares) {
        uint256 maxAssetsDeposit = maxDeposit(receiver);
        if (assets > maxAssetsDeposit) {
            revert ERC4626DepositExceedsMaxLimit(assets, maxAssetsDeposit);
        }

        uint256 sharesToMint = previewDeposit(assets);
        _deposit(_msgSender(), receiver, assets, sharesToMint);
        // afterDeposit(assets, sharesToMint);
        return shares;
    }

    /**
     * Mints `shares` amount of shares tokens to `receiver` by depositing the equivalent amount of assets.
     * @param shares the amount of shares to mint in exchange for assets.
     * @param receiver the address to receive the shares.
     * returns the amount of assets deposited to mint the `shares`.
     */
    function mint(uint256 shares, address receiver) public override returns (uint256 assets) {
        uint256 maxSharesToMint = maxMint(receiver);
        if (shares > maxSharesToMint) {
            revert ERC4626MintExceedsMaxLimit(shares, maxSharesToMint);
        }

        uint256 assetsToDeposit = previewMint(shares);
        _deposit(_msgSender(), receiver, assetsToDeposit, shares);
        // afterMint(assetsToDeposit, shares);
        return assetsToDeposit;
    }

    /**
     * Withraws `assets` amount of assets from the vault by burning the equivalent shares from the `owner`.
     * @param assets amount of assets to withdraw in exchange/to burn shares.
     * @param receiver the receiver of the shares.
     * @param owner the owner of the share tokens.
     * returns the amount of shares burned from the `owner`.
     */
    function withdraw(uint256 assets, address receiver, address owner) public override returns (uint256 shares) {
        uint256 maxAssetsToWithdraw = maxWithdraw(owner);
        if (assets > maxAssetsToWithdraw) {
            revert ERC4626WithdrawExceedsMaxLimit(assets, maxAssetsToWithdraw);
        }

        uint256 sharesToBurn = previewWithdraw(assets);
        _withdraw(_msgSender(), receiver, owner, assets, sharesToBurn);
        // afterWithdraw(assets, sharesToBurn);
        return sharesToBurn;
    }

    /**
     * Redeems `shares` amount of share tokens from the `owner` in exchange for assets.
     * @param shares amount of shares to redeem/burn in exchange/to withdraw assets.
     * @param receiver the receiver of the assets.
     * @param owner the owner of the share tokens.
     * returns the amount of assets withdrawn to the `receiver`.
     */
    function redeem(uint256 shares, address receiver, address owner) public override returns (uint256) {
        uint256 maxSharesToRedeem = maxRedeem(owner);
        if (shares > maxSharesToRedeem) {
            revert ERC4626WithdrawExceedsMaxLimit(shares, maxSharesToRedeem);
        }

        uint256 assetsToWithdraw = previewRedeem(shares);
        _withdraw(_msgSender(), receiver, owner, assetsToWithdraw, shares);
        // afterRedeem(assetsToWithdraw, shares);
        return assetsToWithdraw;
    }
}
