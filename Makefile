.PHONY: build test clean

build:
	forge build

test:
	forge test -vv

clean:
	forge clean

deploy-game:
	forge create src/MinUniqueGame.sol:MinUniqueGame --rpc-url "https://1rpc.io/holesky" --private-key $(MINUNIQUEGAME_OWNER_PRIVATE_KEY) --broadcast
# --constructor-args ...
