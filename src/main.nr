use dep::std;
use dep::std::bigint::Secpk1Fq;

type Point = ([u8; 32], [u8; 32]);

global ZERO = Secpk1Fq::from_le_bytes(&[0]);
global TWO = Secpk1Fq::from_le_bytes(&[2]);
global THREE = Secpk1Fq::from_le_bytes(&[3]);

fn main(
    priv_key: [u8; 32],
    address1: pub Field,
    pub_key_x2: [u8; 32],
    pub_key_y2: [u8; 32],
    address2: pub Field,
    secret_share_x: [u8; 32],
    secret_share_y: [u8; 32]
) {
    let pub_key_xy = multiply_point(priv_key, (get_gx(), get_gy()));
    let addressA = point_xy_to_address(pub_key_xy.0, pub_key_xy.1);
    assert_eq(addressA, address1);

    let addressB = point_xy_to_address(pub_key_x2, pub_key_y2);
    assert_eq(addressB, address2);

    let secret_share_xy = multiply_point(priv_key, (pub_key_x2, pub_key_y2));
    assert_eq(secret_share_xy.0, secret_share_x);
    assert_eq(secret_share_xy.1, secret_share_y);
}

fn point_xy_to_address(pub_key_x: [u8; 32], pub_key_y: [u8; 32]) -> Field {
    let pub_key = u8_32_to_u8_64_unconstrained(pub_key_x, pub_key_y);
    let hashed_pub_key = std::hash::keccak256(pub_key, 64);
    let mut addr: Field = 0;
    for i in 0..20 {
        addr = (addr * 256) + hashed_pub_key[i + 12] as Field;
    }

    addr
}

unconstrained
fn u8_32_to_u8_64_unconstrained(arr_a: [u8; 32], arr_b: [u8; 32]) -> [u8; 64] {
    let mut combined: [u8; 64] = [0; 64];

    for i in 0..32 {
        combined[i] = arr_a[i];
    }
    for i in 0..32 {
        combined[i + 32] = arr_b[i];
    }

    combined
}

pub fn multiply_point(scalar: [u8; 32], p: Point) -> Point {
    let mut res = (ZERO, ZERO);
    let mut p = (Secpk1Fq::from_le_bytes(to_u8_arr(p.0)), Secpk1Fq::from_le_bytes(to_u8_arr(p.1)));

    for i in 0..32 {
        let byte = (scalar[i] as Field).to_le_bits(8);

        for j in 0..8 {
            if byte[j] == 1 {
                if res == (ZERO, ZERO) {
                    res = p;
                } else {
                    res = add_point(res.0, res.1, p.0, p.1);
                }
            }
            p = double_point(p.0, p.1);
        }
    }
    (to_u8_32(res.0.to_le_bytes()), to_u8_32(res.1.to_le_bytes()))
}

fn double_point(x: Secpk1Fq, y: Secpk1Fq) -> (Secpk1Fq, Secpk1Fq) {
    let s = (THREE * x * x) / (TWO * y);
    let x3 = s * s - TWO * x;
    let y3 = s * (x - x3) - y;
    (x3, y3)
}

fn add_point(x0: Secpk1Fq, y0: Secpk1Fq, x1: Secpk1Fq, y1: Secpk1Fq) -> (Secpk1Fq, Secpk1Fq) {
    let s = (y0 - y1) / (x0 - x1);
    let x2 = (s * s - x0 - x1);
    let y2 = (s * (x0 - x2) - y0);
    (x2, y2)
}

pub fn to_u8_arr<N>(smth: [u8; N]) -> [u8] {
    smth
}

pub fn to_u8_32(smth: [u8]) -> [u8; 32] {
    let mut res = [0 as u8; 32];
    for i in 0..smth.len() {
        res[i] = smth[i];
    }
    res
}

fn get_gx() -> [u8; 32] {
    [
        152, 23, 248, 22, 91, 129, 242, 89,
        217, 40, 206, 45, 219, 252, 155, 2,
        7, 11, 135, 206, 149, 98, 160, 85,
        172, 187, 220, 249, 126, 102, 190, 121
    ]
}

fn get_gy() -> [u8; 32] {
    [
        184, 212, 16, 251, 143, 208, 71, 156,
        25, 84, 133, 166, 72, 180, 23, 253,
        168, 8, 17, 14, 252, 251, 164, 93,
        101, 196, 163, 38, 119, 218, 58, 72
    ]
}

#[test]
fn test_main() {}
