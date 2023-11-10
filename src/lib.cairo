#[starknet::contract]
mod c1 {
    use alexandria_storage::list::{ListTrait, List};
    use starknet::ContractAddress;

    #[derive(Drop, Copy, Serde, starknet::Store)]
    struct MyStruct {
        a: Option<MyOptionStruct>,
        b: felt252,
    }

    #[derive(Drop, Copy, Serde, starknet::Store)]
    struct MyOptionStruct {
        c: Option<u32>, // comment this line and it works
        d: u32,
    }

    #[storage]
    struct Storage {
        data: LegacyMap<felt252, List<MyStruct>>,
    }

    fn get(ref self: ContractState, account: felt252, index: u32) -> Option<MyStruct> {
        let mut list: List<MyStruct> = self.data.read(account);
        list.get(index)
    }

    fn append(ref self: ContractState, account: felt252, val: MyStruct) {
        let mut list: List<MyStruct> = self.data.read(account);
        list.append(val);
    }

    fn set(ref self: ContractState, account: felt252, index: u32, val: MyStruct) {
        let mut list: List<MyStruct> = self.data.read(account);
        list.set(index, val);
    }
}

#[cfg(test)]
mod tests {
    use core::option::OptionTrait;
    use debug::PrintTrait;
    use super::c1;
    use super::c1::MyStruct;
    use super::c1::MyOptionStruct;

    #[test]
    #[available_gas(20000000)]
    fn test1() {
        let mut state: c1::ContractState = c1::unsafe_new_contract_state();
        
        let s = MyStruct {
            a: Option::None,
            b: 10,
        };
        let option_struct = MyOptionStruct {
            
            c: Option::Some(10), // comment this line and it works
            d: 20,
        };

        c1::append(ref state, 0, s);

        let mut v = c1::get(ref state, 0, 0).expect('fail 0');
        v.a = Option::Some(option_struct);
        c1::set(ref state, 0, 0, v);

        let v2 = c1::get(ref state, 0, 0).expect('fail 1');
        v2.a.unwrap().d.print();
    }
}