# ERC20LikeToken (Foundry Project)

## Overview

A minimal ERC20 token implementation built from scratch (no OpenZeppelin).
Designed to deeply understand **token mechanics, state transitions, and invariant testing**.

---

## Features

* Transfer tokens between accounts
* Approve & transferFrom (allowance system)
* Increase / decrease allowance
* Owner-restricted minting
* Token burning

---

## Testing

This project includes:

### Unit Tests

* Transfer / transferFrom
* Approve & allowance updates
* Mint / burn logic
* Revert scenarios (zero address, insufficient balance, unauthorized mint)

### Fuzz Testing

* Randomized inputs for transfers, approvals, and mint/burn
* Edge case validation across different users

### Invariant Testing (Handler-based)

* Total supply follows mint/burn accounting
* No user balance exceeds total supply
* Zero address never holds tokens
* System remains consistent under random interactions

---

## Key Concepts

* ERC20 mechanics from scratch
* Allowance system design
* Handler-based invariant testing
* Fuzzing with multiple actors
* Adversarial testing (invalid inputs, zero address)

---

## Tech Stack

* Solidity ^0.8.20
* Foundry

---

## Run Locally

```bash
forge install
forge build
forge test
```

---

##  Notes
* Uses try/catch in Handler to allow invariant fuzzing across failing calls
* Includes edge case testing (zero address, random users)
* Not production-ready, built for learning and testing

---

## Project Structure
```text
src/
  └── ERC20LikeToken.sol

test/
  ├── ERC20LikeTokenTest.t.sol
  └── invariant/
      ├── Handler.sol
      └── ERC20InvariantTest.sol
```

---

##  Goal

To understand ERC20 design, testing strategies, and system-level correctness through fuzzing and invariants.