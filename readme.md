# ECDH ZKP

This code implements a zero-knowledge proof (ZKP) circuit designed to verify the correct generation of a shared secret key from Ethereum addresses on-chain.


## Operations

1. Multiply the private key by the generator point G to obtain pub_key_xy.
2. Convert pub_key_xy to an address addressA and verify it matches address1.
3. Convert the coordinates pub_key_x2, pub_key_y2 to an address addressB and verify it matches address2.
4. Multiply the private key by (pub_key_x2, pub_key_y2) to obtain secret_share_xy and verify it matches secret_share_x and secret_share_y.


## Information

| Package | Function | Expression Width     | ACIR Opcodes |
|---------|----------|----------------------|--------------|
| ECDH    | main     | Bounded { width: 4 } | 1,592,841    |
