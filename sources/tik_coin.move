module tik_supply::tikcoin {

    use sui::coin::{Self, Coin,TreasuryCap};
    use sui::tx_context::{sender};
    use sui::balance::{Self, Balance, Supply};
    use sui::event;
    use sui::clock::{Self, Clock};
    use tik_supply::mine::{Miner,Epochs};
    use tik_supply::icon::{get_icon_url};
    public struct SupplyEvent has copy, drop {
        totalsupply: u64,
    }
    public struct TIKCOIN  has drop {}

    public struct Treasury<phantom T> has key, store {
        id: UID,
        treasuryCap: TreasuryCap<TIKCOIN>,
        CirculatingSupply:u128,
        CmtyAccount:address,
    }
    public struct CmtyCap has key, store {
        id: UID
    }

    fun init(witness: TIKCOIN, ctx: &mut TxContext) {
        let (mut treasury_cap, metadata)
            = coin::create_currency<TIKCOIN>(
            witness,
            12, 
            b"TIK", 
            b"TIKCOIN", 
            b"Time Flies, TIK Stays! Everyone Gets a Fair Chance to Mine and Earn Rewards!", 
            option::some(get_icon_url()),
            ctx
        );
        transfer::public_freeze_object(metadata);

        let treasury = Treasury<TIKCOIN> {
            id: object::new(ctx),
            treasuryCap:treasury_cap,
            CirculatingSupply:0,
            CmtyAccount:sender(ctx),
        };
       transfer::share_object(treasury);

       let  cmtycap= CmtyCap{ id: object::new(ctx)};
       transfer::transfer(cmtycap, sender(ctx));

    }

    public entry fun claim(treasury:&mut Treasury<TIKCOIN>,miner: &mut Miner,epochs: &Epochs,  clock: &Clock,ctx: &mut TxContext )
    {
       let claimab= tik_supply::mine::claim(miner,epochs,clock,ctx);
       if  (claimab>0)
       {
            let cmty: u128 = (claimab * 1) / 100;
            let miner_rewards:u128=claimab-cmty;
            coin::mint_and_transfer(&mut treasury.treasuryCap,miner_rewards as u64,sender(ctx),ctx);
            coin::mint_and_transfer(&mut treasury.treasuryCap,cmty as u64,treasury.CmtyAccount,ctx);
            treasury.CirculatingSupply=treasury.CirculatingSupply+ claimab ;
       }
       
    }
    public entry fun set_community_account(treasury:&mut Treasury<TIKCOIN>, cmtycap:&CmtyCap, newaddr:address,ctx: &mut TxContext)
    {
          treasury.CmtyAccount=newaddr;
    }

    public entry fun show_total_supply(treasury:&Treasury<TIKCOIN>): u64 {
          let total_supply = coin::total_supply(&treasury.treasuryCap);
          event::emit(SupplyEvent { totalsupply : total_supply });
          total_supply
     }   

}
