// SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

import {ERC4626} from "@openzeppelin/contracts/token/ERC20/extensions/ERC4626.sol";

abstract contract ERC4626Strategy is ERC4626 {
    /**
     * Deopsites `assets` amount of underlying tokens in exchange for shares.
     * @param assets the assets to be deposited in exchange for shares.
     * @param receiver the address to receive the shares.
     * return the number of shares to be sent to the receiver.
     */
    function deposit(uint256 assets, address receiver) public override returns (uint256 shares) {
        require(assets > 0, "Deposit amount must be greater than zero");
        require(assets <= maxDeposit(receiver), "Deposit exceeds max limit");

        uint256 sharesToMint = previewDeposit(assets);
        _deposit(_msgSender(), receiver, assets, sharesToMint);
        return sharesToMint;
    }

    /**
     * Mints `shares` amount of shares to the `receiver` by depositing assetss.
     * @param shares the amount of shares to be exchanged for tokens(caller must have a balance => `shares`).
     * @param receiver the address that should receeive the assets eexchanged for shares.
     * returns the amount of assets deposited in exchange for shares.
     */
    function mint(uint256 shares, address receiver) public virtual override returns (uint256 assets) {
        require(shares > 0, "Mint amount must be greater than zero");
        require(shares <= maxMint(receiver), "Mint exceeds max limit");

        uint256 assetsToDeposit = previewMint(shares);
        _deposit(_msgSender(), receiver, assetsToDeposit, shares);
        afterDeposit(assetsToDeposit, shares);
        return assetsToDeposit;
    }

    /**
     * Redeems `shares` amount of shares from the `owner` by withdrawing assets.
     * @param shares the amount of shares to be redeemed.
     * @param receiver the address that should receive the assets.
     * @param owner the address of the owner of the shares.
     * returns the amount of assets withdrawn in exchange for shares.
     */
    function redeem(uint256 shares, address receiver, address owner) public virtual override returns (uint256 assets) {
        require(shares > 0, "Redeem amount must be greater than zero");
        require(shares <= maxRedeem(owner), "Redeem exceeds max limit");

        uint256 assetsToWithdraw = previewRedeem(shares);
        beforeWithdraw(assetsToWithdraw, shares);
        _withdraw(_msgSender(), receiver, owner, assetsToWithdraw, shares);
        return assetsToWithdraw;
    }

    function withdraw(uint256 assets, address receier, address owner)
        public
        virtual
        override
        returns (uint256 shares)
    {
        require(assets > 0, "Withdraw amount must be greater than zero");
        require(assets <= maxWithdraw(owner), "Withdraw exceeds max limit");

        uint256 sharesToBurn = previewWithdraw(assets);
        beforeWithdraw(assets, sharesToBurn);
        _withdraw(_msgSender(), receier, owner, assets, sharesToBurn);
        return sharesToBurn;
    }

    function beforeWithdraw(uint256 assets, uint256 shares) internal virtual {}

    function afterDeposit(uint256 assets, uint256 shares) internal virtual {}
}
